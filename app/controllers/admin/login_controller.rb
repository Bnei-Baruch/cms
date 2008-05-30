class Admin::LoginController < ApplicationController
  layout 'not_admin'

  def login

    if request.post?
      autonticate
    end

  end
  # alias_method :index,:login

  def index
    render :action => 'login'
  end

  # POST /login
  def create
    autonticate
  end

  def logout
    session[:user_id] = nil
    session[:current_user_is_admin] = nil
    session[:current_user_is_anonymous] = nil
    flash[:notice] = "Logged out"
    redirect_to(:action => "login")
  end


  private
  
  def autonticate
     session[:user_id] = nil
      user = User.authenticate(params[:login], params[:password])
      if user
        session[:user_id] = user.id
        session[:current_user_is_admin] = user.groups.find(:all, :conditions => {:groupname=>'Administrators'}).length
        session[:current_user_is_anonymous] = nil

        uri= session[:original_uri]
        session[:original_uri]=nil
        redirect_to(uri || admin_resources_path)
      else
        flash.now[:notice] = "Invalid user/password combination"
        render :action => "login" 
      end
  end
  
end
