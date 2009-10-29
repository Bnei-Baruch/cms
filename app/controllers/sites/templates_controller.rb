class Sites::TemplatesController < ApplicationController
  include TemplateExtensions
  attr_reader :website
  
  # Add the 'app/sites' path of sites which is used by the application instead of regular 'app/views' folder
  # custom_view_path = "#{RAILS_ROOT}/app/sites"
  # self.prepend_view_path(custom_view_path)
  
  def update_positions
    nodes = YAML.load(params[:nodes]) rescue []
    positions = params[params[:key]] rescue []
    begin
      result = TreeNode.update_positions(nodes, positions) ? 200 : 500
      render :nothing => true, :status => result and return
    rescue => exception
      render :text => exception.message, :status => 500 and return
    end

  end
  
  # This is the action that renders the view and responds to client
  def template
    if params[:path].kind_of?(Array) && params[:path][2] =~ /\.jpg|\.gif|\.png/
      render :nothing => true
      return
    end
    
    PageMap.reset_tree_nodes_list

    if params[:logout]
      AuthenticationModel.logout_from_admin

      # Upon logout we'd like to press Back in browser and refresh the page
      # So we need to remove the logout=true from URL.
      redirect_to request.url.sub(/logout=true/,'').sub(/\?$/,'')
      return
    end
    
    @ip = request.remote_ip
    unless @website
      # External link
      check_url_migration(true)
      return
    end

    unless @presenter
      head_status_404
      return
    end

    # in case the page is not found in the DB
    unless @presenter.node
      # Internal link
      check_url_migration
      return
    end

    respond_to do |format|
      format.html do
        if request.xhr?
          render_json_widget
          return
        end 
        resource = @presenter.node_resource_type.hrid
        klass = t_class(resource)
        layout_class = l_class(resource)
        if AuthenticationModel.current_user_is_anonymous?
          # To cache even in development mode change
          #       Rails.env == 'development'
          # to
          #       false
          # Do not forget to uncomment correspondent lines in development.rb
          nocache = params[:nocache]
          if Rails.env == 'development' || nocache || @presenter.site_settings[:cache][:disable_cache]
            render :widget => klass, :layout_class => layout_class
          else
            key = @presenter.node.this_cache_key
            if result = Rails.cache.fetch(key)
              render :text => result if stale?(:etag => result)
            else
              Rails.cache.write(key,
                render(:widget => klass, :layout_class => layout_class))
              # Store the list of tree nodes used to render the current page
              PageMap.save_tree_nodes_list
            end
          end
        else
          # Authenticated user ==> no cache
          render :widget => klass, :layout_class => layout_class
        end
      end
      format.json do
        render_json_widget
        return
      end
      format.rss {
        render_feed('rss')
        return
      }
      format.atom {
        render_feed('atom')
        return
      }
    end

  end

  def render_feed(feed_type)
    Thread.current[:skip_page_map] = true
    node_id = @presenter.node.id
    acts_as_section = @presenter.node.resource.properties('acts_as_section').get_value rescue false
    if (@presenter.is_homepage? ||
          (@presenter.node_resource_type.hrid == 'content_page' && acts_as_section))
      feed = Feed.find(:first, :conditions => [ "section_id = ? AND feed_type = ?", node_id, feed_type]) rescue nil
      unless feed
        limit = @presenter.site_settings[:rss_items_limit] || 10
        @pages = TreeNode.get_subtree(
          :parent => node_id,
          :resource_type_hrids => ['content_page'],
          :has_url => true,
          :is_main => true,
          :limit => limit,
          :order => "created_at DESC",
          :status => ['PUBLISHED']
        )
        feed = Feed.new(:section_id => node_id,
          :feed_type => feed_type,
          :data => (render :layout => false))
        feed.save
      else
        render :text => feed.data
      end
    else
      head_status_404
    end
    Thread.current[:skip_page_map] = false
  end

  def render_json_widget
    Thread.current[:skip_page_map] = true
    options = params[:options]
    unless options && options.has_key?(:widget)
      status_404
      return
    end
    widget = options[:widget]
    options[:node] = params[:node] if params.has_key?(:node)
    tree_node = TreeNode.find(options[:widget_node_id]) rescue nil

    begin
      result = render_to_string(:widget => w_class(widget), :tree_node => tree_node,
        :view_mode => params[:view_mode], :options => options, :layout => false)
      render :json => result
      #      render :json => w_class(widget).new(:tree_node => tree_node, :view_mode => params[:view_mode], :options => options).to_s
    rescue Exception => ex
      render :text => ex, :status => 500
    end

    Thread.current[:skip_page_map] = false
  end

  def sitemap

    if @website.nil?
      head_status_404
      return
    end
    
    @pages = []
    begin
      website_node = @website.website_resource.tree_nodes.main
      if (website_node)
        @pages = TreeNode.get_subtree(
          :parent => website_node.id, 
          :resource_type_hrids => ['content_page'],
          :has_url => true,
          :is_main => true,
          :status => ['PUBLISHED']
        )
      end
    rescue Exception => e
      head_status_404
      return
    end
    render :layout => false
  end
  
  def stylesheet
    style_id = params[:css_id]

    unless @presenter || @website
      head_status_404
      return
    end

    respond_to do |format|
      format.css { render :template => my_stylesheets_path(style_id)}
    end
    
  end

  def redirect_301(url)
    headers["Status"] = '301 Moved Permanently'
    redirect_to url
  end

  def redirect_302(url)
    headers["Status"] = '302 Moved Temporarily'
    redirect_to url
  end

  def status_404
    # render_widget :type => 'template', :widget => 'status', :view_mode => 'status404', :layout => false
    head_status_404
  end
  
  def head_status_404
  
    permanlink = site_settings[:page404_permalink] rescue nil
    if permanlink && (@presenter = set_presenter(permanlink)) && @presenter.node
      resource = @presenter.node_resource_type.hrid
      klass = t_class(resource)
      layout_class = l_class(resource)
      render :widget => klass, :layout_class => layout_class, :render_options => {:status => 404}
      return
    else
      render :template => 'sites/templates/404.html.erb',:status => 404
      return
    end
  end
  
  def status_410
    render :text => "Redirected back to the reverse proxy to show old site page.\r\n", :status => 410
  end
  
  
  def check_url_migration(is_external = false)
    url = request.request_uri.dup
    migration = UrlMigration.get_action_and_target('http://' + request.env["HTTP_HOST"] + url)
    if migration.nil?
      slash = "/"
      if url[url.length - 1] != slash[0]
        url = url + '/'
      else
        url.chop!
      end
      migration = UrlMigration.get_action_and_target('http://' + request.env["HTTP_HOST"] + url)
    end
    
    unless migration.nil?
      case migration[:status]
      when $config_manager.appl_settings[:url_migration_action][:action_404]:
          head_status_404         
      when $config_manager.appl_settings[:url_migration_action][:action_301]:
          redirect_301(migration[:target])
      end
    else
      if is_external
        status_410
      else
        status_404
      end
    end
  end
end
