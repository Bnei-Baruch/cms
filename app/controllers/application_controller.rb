# Filters added to this controller apply to all controllers in the application. Likewise,
# all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
	
	before_filter :activate_global_parms, :set_website, :set_presenter, :set_translations 
  
	def set_website_session(show_all_websites)
		if show_all_websites
			session[:website] = nil
		else
			website = Website.find(params[:website_id])
			session[:website] = website.id if website
    end
	end

  def site_settings
    website = @website ? @website.hrid : 'global'
    $config_manager.site_settings(website)
  end

  def site_name
    site_settings[:site_name]
  end
  
  def group_name
    site_settings[:group_name]
  end
  
  def admin_authorize(groups=[])
    m_user = User.find_by_id(session[:user_id])
    unless m_user
      session[:original_uri]=request.request_uri
      flash[:notice] = "Access denied."
      redirect_to(:controller => "login", :action => "login")
    else
      groups<<'Administrators'
      user_groups = m_user.groups.find(:all, :conditions => [ "groupname IN (?) and (Length(reason_of_ban)=0 or reason_of_ban is null)", groups])
      if (user_groups.length == 0)
        session[:original_uri]=request.request_uri
        flash[:notice] = "Access denied."
        redirect_to(:controller => "login", :action => "login", :status => 401)
      end
    end
  end
    
  protected

  def save_referrer_to_session
    session[:referer] = request.env["HTTP_REFERER"]
  end

  private

  def activate_global_parms
    # Pick a unique cookie name to distinguish our session data from others'
    request.session_options[:session_key] = '_cms_session_id'

    if session[:user_id].nil?
      anonymous = AuthenticationModel.get_anonymous_user
      user = User.authenticate(anonymous[:username], anonymous[:password])
      if user
        session[:user_id] = user.id
        session[:current_user_is_admin] = 0
        session[:current_user_is_anonymous] = 1
      else
        logger.error("Anonymous user is not defined or banned. Access denied.")
        raise "Access denied for anonymous user."
      end
    end
    Thread.current[:session] = session
  end

  def set_website
    @host = 'http://' + request.host
    @prefix = params[:prefix]
    @permalink = params[:permalink]
    @path = params[:path]
    if @prefix || @permalink
      @website = Website.find(:first, :conditions => ['domain = ? and prefix = ?', @host, @prefix])
      @website = nil if @website && @website.use_homepage_without_prefix && !(@prefix && @permalink)
    elsif !@path || (@path && @path.empty?)
      @website = Website.find(:first, :conditions => ['domain = ? and use_homepage_without_prefix = ?', @host, true])
    end
  end

  def set_translations
    @site_direction = session[:site_direction] = site_settings[:site_direction] || 'ltr'
    @site_name = session[:site_name] = site_settings[:site_name] || 'global'
    @language = session[:language] = site_settings[:language] || 'default'
    I18n.load_path += Dir[ File.join(RAILS_ROOT, 'lib', 'locale', '*.{rb,yml}') ]
    I18n.locale = @language
  end

  def set_presenter
    args = {:permalink => @permalink, :website=> @website, :controller => self}
    begin
      @presenter = get_presenter(site_name, group_name, args)
    rescue Exception => e
      @presenter = nil
    end
    Thread.current[:presenter] = @presenter
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
  
end
