class Admin::LoginController < ApplicationController
  layout 'not_admin'

  def login

    if request.post?
      authenticate
    end

  end
  # alias_method :index,:login

  def index
    render :action => 'login'
  end

  # POST /login
  def create
    authenticate
  end

  def logout
    session[:user_id] = nil
    session[:current_user_is_admin] = nil
    session[:current_user_is_anonymous] = nil
    flash[:notice] = "Logged out"
    redirect_to(:action => "login")
  end


  private
  
  def authenticate
     session[:user_id] = nil
      user = User.authenticate(params[:login], params[:password])
      if user
        session[:user_id] = user.id
        session[:current_user_is_admin] = user.groups.find(:all, :conditions => {:groupname=>'Administrators'}).length
        session[:current_user_is_anonymous] = nil

        uri= session[:original_uri]
        session[:original_uri]=nil
        redirect_to(uri || user_home_page(user.website_id))
      else
        flash.now[:notice] = "Invalid user/password combination"
        render :action => "login" 
      end
  end
  
  def user_home_page(user_website_id)
    if user_website_id
      website = Website.find(user_website_id)
      if website
        my_port = request.server_port.to_s
        my_port = (my_port == '80' ? '' : ':' + my_port)
        prefix = ''
        prefix = '/' + website.prefix unless website.use_homepage_without_prefix
        website.domain + my_port + prefix
      else
        admin_tree_nodes_path
      end
    else
      admin_tree_nodes_path
    end
  end
  
end
