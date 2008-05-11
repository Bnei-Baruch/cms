class Sites::TemplatesController < ApplicationController

  attr_reader :website

  # Add the 'app/sites' path of sites which is used by the application instead of regular 'app/views' folder
  custom_view_path = "#{RAILS_ROOT}/app/sites"
  self.prepend_view_path(custom_view_path)
  
  def json(id = params[:node])
    respond_to do |format|
    end
    
  end
  
  # This is the action that renders the view and responds to client
  def template
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
    Thread.current[:presenter] = @presenter

    # in case the page is not found in the DB
    unless @presenter.node 
      status_404 
      return
    end

    respond_to do |format|
      format.html { 
        resource = @presenter.node_resource_type.hrid
        render :text => t_class(resource).new(
          :layout_class => l_class(resource)
        ).to_s
      }
      format.json {
        unless params.has_key?(:widget)
          status_404
          return
        end
        widget = params[:widget]
        options = params.reject { |key, value|
          ['view_mode', 'widget', 'prefix', 'format', 'action', 'id', 'controller'].include?(key) }
        render :json => w_class(widget).new(:view_mode => params[:view_mode], :options => options).render_to(self)
      }
    end

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
  
  def site_settings
    $config_manager.site_settings(@website.hrid)
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
    my_layout_path(resource).camelize.constantize
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
  
  def get_my_path(type, sitename, groupname, filename, extention)
    if File.exists?("#{RAILS_ROOT}/app/sites/#{sitename}/#{type}/#{filename}.#{extention}")
      "#{sitename}/#{type}/#{filename}"
    elsif File.exists?("#{RAILS_ROOT}/app/sites/#{groupname}/#{type}/#{filename}.#{extention}")
      "#{groupname}/#{type}/#{filename}"
    else 
      "global/#{type}/#{filename}"
    end  
  end
  
end
