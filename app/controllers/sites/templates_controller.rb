class Sites::TemplatesController < ApplicationController

  # to be able to use this method in the views
  helper_method :render_widget

  # Add the 'app/sites' path of sites which is used by the application instead of regular 'app/views' folder
  custom_view_path = "#{RAILS_ROOT}/app/sites"
  self.prepend_view_path(custom_view_path)
  
  # This is the action that renders the view and responds to client
  def template
    # render :text => request.host.to_s + "<br /> Prefix: " + params[:prefix] + "<br /> Prefix: " + params[:id]
    host = 'http://' + request.host
    prefix = params[:prefix]
    permalink = params[:id]
    @website = Website.find(:first, :conditions => ['domain = ? and prefix = ?', host, prefix])
    @site_name = site_name

    args = {:permalink => permalink, :website=> @website, :controller => self}
    begin
      @presenter = get_presenter(site_name, group_name, args)
    rescue Exception => e
      head_status_404
      return
    end

    # in case the page is not found in the DB
    unless @presenter.node 
      status_404 
      return
    end

    respond_to do |format|
      format.html { render_widget :type => 'template', :widget => @presenter.node_resource_type.hrid}
    end

  end
  
  def stylesheet
    website_id = params[:website_id]
    style_id = params[:css_id]
    @website = Website.find(website_id)
    @site_name = site_name
    respond_to do |format|
      format.css { render :template => stylesheets_path(style_id)}
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
    render_widget :type => 'template', :widget => 'status', :view_mode => 'status404', :layout => false
  end
  
  def head_status_404
    render :file => 'public/404.html', :status => 404
  end
  
  def site_settings
    $config_manager.site_settings(@website.hrid)
  end
  
  def site_name
    site_settings[:site_name]
  end
  
  def group_name
    site_settings[:group_name]
  end
  
  def template_path(resource, view_mode)
    get_template_path(site_name, group_name, resource, view_mode)
  end

  def stylesheets_path(style_name)
    get_stylesheets_path(site_name, group_name, style_name)
  end

  def layout_path(resource)
    get_layout_path(site_name, group_name, resource)
  end

  def widget_path(resource)
    get_widget_path(site_name, group_name, resource)
  end
  
  # Create the class name of the widget
  def widget_class(resource)
    widget_path(resource).camelize.constantize 
  end

  # args:
  # :type - required - options: 'template', 'partial'
  # :widget - required - the name of the widget
  # :view_mode - optional - default: 'full' - the name of the view mode. 
  #              the same widget could have different views
  # :layout - optional - default: When template - the name of the widget in layouts folder
  #                               When partial - false
  # :locals - optional - the hash of args to pass to the widget. accessed through @widget.externals

  # render widget as partial with layout 
  # (layout of partial will be put in the same folder where the partial is):
  # render_widget :type => partial, :widget => 'content_page', :layout => 'large'
  # render widget as template with layout
  # render_widget :type => template, :widget => 'content_page', :vew_mode => 'small', :layout => 'large'
  def render_widget(args = {})
    w_class = widget_class(args[:widget])
    widget = w_class.new(args, @presenter)
    render_options = widget.render_me.merge({:locals => {:widget => widget}})
    if render_options.has_key?(:partial)
      render_to_string render_options
    else
      render render_options
    end
  end
  
  private     

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

  def get_template_path(sitename, groupname, resource, view_mode)
    if File.exists?("#{RAILS_ROOT}/app/sites/#{sitename}/templates/#{resource}/#{view_mode}.html.erb")
      "#{sitename}/templates/#{resource}/#{view_mode}"
    elsif File.exists?("#{RAILS_ROOT}/app/sites/#{groupname}/templates/#{resource}/#{view_mode}.html.erb")
      "#{groupname}/templates/#{resource}/#{view_mode}"
    else
      "global/templates/#{resource}/#{view_mode}"
    end  
  end

  def get_stylesheets_path(sitename, groupname, stylename)
    if File.exists?("#{RAILS_ROOT}/app/sites/#{sitename}/stylesheets/#{stylename}.css.erb")
      "#{sitename}/stylesheets/#{stylename}"
    elsif File.exists?("#{RAILS_ROOT}/app/sites/#{groupname}/stylesheets/#{stylename}.css.erb")
      "#{groupname}/stylesheets/#{stylename}"
    else
      "global/stylesheets/#{stylename}"
    end  
  end

  def get_layout_path(sitename, groupname, resource)
    if File.exists?("#{RAILS_ROOT}/app/sites/#{sitename}/layouts/#{resource}.html.erb")
      "#{sitename}/layouts/#{resource}"
    elsif File.exists?("#{RAILS_ROOT}/app/sites/#{groupname}/layouts/#{resource}.html.erb")
        "#{groupname}/layouts/#{resource}"
    else 
      "global/layouts/#{resource}"
    end  
  end

  def get_widget_path(sitename, groupname, resource)
    if File.exists?("#{RAILS_ROOT}/app/sites/#{sitename}/widgets/#{resource}.rb")
      "#{sitename}/widgets/#{resource}"
    elsif File.exists?("#{RAILS_ROOT}/app/sites/#{groupname}/widgets/#{resource}.rb")
        "#{groupname}/widgets/#{resource}"
    else 
      "global/widgets/#{resource}"
    end  
  end
  
end
