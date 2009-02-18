class Sites::TemplatesController < ApplicationController

  attr_reader :website
  
  # Add the 'app/sites' path of sites which is used by the application instead of regular 'app/views' folder
  # custom_view_path = "#{RAILS_ROOT}/app/sites"
  # self.prepend_view_path(custom_view_path)
  
  def json(id = params[:node])
    respond_to do |format|
    end
  end
  
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
    CacheMap.reset_tree_nodes_list

    host = 'http://' + request.host
    prefix = params[:prefix]
    permalink = params[:id]
    path = params[:path]
    
    logout = params.has_key?('logout') ? params[:logout] : false
    AuthenticationModel.logout_from_admin if logout
    
    @ip = request.remote_ip
    if prefix || permalink
      @website = Website.find(:first, :conditions => ['domain = ? and prefix = ?', host, prefix])
      @website = nil if @website && @website.use_homepage_without_prefix && !(prefix && permalink)
    elsif !path || (path && path.empty?)
      @website = Website.find(:first, :conditions => ['domain = ? and use_homepage_without_prefix = ?', host, true])
    end
    unless @website
      # External link
      check_url_migration(true)
      return
    end
    
    args = {:permalink => permalink, :website=> @website, :controller => self}
    begin
      @presenter = get_presenter(site_name, group_name, args)
    rescue Exception => e
      head_status_404
      return
    end
    @site_name = site_name
    Thread.current[:presenter] = @presenter

    # in case the page is not found in the DB
    unless @presenter.node
      # Internal link
      check_url_migration
      return
    end

    session[:site_direction] = site_settings[:site_direction] rescue 'rtl'
    session[:language] = site_settings[:language] rescue 'default'
    set_translations
    
    respond_to do |format|
      format.html {
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
          #       Rails.env != 'development'
          # Do not forget to uncomment correspondent lines in development.rb
          if Rails.env == 'development'
            render :widget => klass, :layout_class => layout_class
          else
            key = @presenter.node.this_cache_key
            if result = Rails.cache.fetch(key)
              render :text => result if stale?(:etag => result)
            else
              Rails.cache.write(key,
                render(:widget => klass, :layout_class => layout_class))
            end
            # Store the list of tree nodes used to render the current page
            CacheMap.save_tree_nodes_list
          end
        else
          # Authenticated user ==> no cache
          render :widget => klass, :layout_class => layout_class
          logger.debug("List of tree nodes used to render page #{@presenter.node.this_cache_key}: #{CacheMap.print_tree_nodes_list}")
          CacheMap.save_tree_nodes_list
        end
      }
      format.json {
        render_json_widget
        return
      }
    end

  end
  
  def render_json_widget
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

  end
  
  def sitemap
    host = 'http://' + request.host
    @website = Website.find(:first, :conditions => ['domain = ? and prefix = ?', host, params[:prefix]]) rescue nil
    if @website.nil?
      head_status_404
      return
    end
    
    @pages = []
    args = {:website=> @website, :controller => self}
    begin
      @presenter = get_presenter(site_name, group_name, args)
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
    website_id = params[:website_id]
    style_id = params[:css_id]
    @website = Website.find(website_id)
    @site_name = site_name

    args = {:website=> @website, :controller => self}
    begin
      @presenter = get_presenter(site_name, group_name, args)
    rescue Exception => e
      head_status_404
      return
    end

    session[:language] = site_settings[:language] rescue 'english'
    set_translations

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
    render :file => 'public/404.html', :status => 404
  end
  
  def status_410
    render :text => "Redirected back to the reverse proxy to show old site page.\r\n", :status => 410
  end
  
  def site_name
    site_settings[:site_name]
  end
  
  def group_name
    site_settings[:group_name]
  end
  
  def w_class(resource)
    my_widget_path(resource).camelize.constantize 
  end
  
  def t_class(resource)
    my_template_path(resource).camelize.constantize
  end

  def l_class(resource)
    l_class_str = site_settings[:layout_map][resource]
    l_class_str = resource if l_class_str.nil?
    my_layout_path(l_class_str).camelize.constantize
  end

  private     

  def my_layout_path(resource)
    get_layout_path(site_name, group_name, resource)
  end

  def my_template_path(resource)
    get_template_path(site_name, group_name, resource)
  end

  def my_stylesheets_path(style_name)
    get_stylesheets_path(site_name, group_name, style_name)
  end

  def my_widget_path(resource)
    get_widget_path(site_name, group_name, resource)
  end
  
  def get_presenter(sitename, groupname, args)
    if File.exists?("#{RAILS_ROOT}/app/models/sites/#{sitename}.rb")
      klass = 'sites/' + sitename
    elsif File.exists?("#{RAILS_ROOT}/app/models/sites/#{groupname}.rb")
      klass = 'sites/' + groupname
    else
      klass = 'sites/global'
    end  
    klass.camelize.constantize.new(args)
  end

  def get_stylesheets_path(sitename, groupname, filename)
    get_my_path('stylesheets', sitename, groupname, filename, 'css.erb')
  end
  
  def get_layout_path(sitename, groupname, filename)
    get_my_path('layouts', sitename, groupname, filename, 'rb')
  end

  def get_template_path(sitename, groupname, filename)
    get_my_path('templates', sitename, groupname, filename, 'rb')
  end
    
  def get_widget_path(sitename, groupname, filename)
    get_my_path('widgets', sitename, groupname, filename, 'rb')
  end
  
  $files_location = Array.new
  
  def get_my_path(type, sitename, groupname, filename, extention)
    search_res = search_path(type, sitename, groupname, filename, extention)
      
    return search_res if search_res
    
    if File.exists?("#{RAILS_ROOT}/app/sites/#{sitename}/#{type}/#{filename}.#{extention}")
      insert_path(type, sitename, filename, extention)
      "#{sitename}/#{type}/#{filename}"
    elsif File.exists?("#{RAILS_ROOT}/app/sites/#{groupname}/#{type}/#{filename}.#{extention}")
      insert_path(type, groupname, filename, extention)
      "#{groupname}/#{type}/#{filename}"
    else 
      insert_path(type, 'global', filename, extention)
      "global/#{type}/#{filename}"
    end
  end
  
  def insert_path(type, name, filename, extention)
    $files_location << {:type => type, :name => name, :filename => filename, :extention => extention}
  end
  
  def search_path(type, sitename, groupname, filename, extention)
    search_res = $files_location.index({:type => type, :name => (sitename || groupname || 'global'), :filename => filename, :extention => extention})
    if search_res
      "#{$files_location[search_res][:name]}/#{type}/#{filename}"
    else
      nil
    end
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
