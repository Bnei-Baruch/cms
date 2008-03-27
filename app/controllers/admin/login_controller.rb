class Admin::LoginController < ApplicationController
  layout 'admin'

  def login
    
    if request.post?
      session[:user_id] = nil
      user = User.authenticate(params[:login], params[:password])
      if user
        session[:user_id] = user.id
        session[:user_is_admin] = user.groups.find(:all, :conditions => {:groupname=>'Administrators'}).length
        
	uri= session[:original_uri]
	session[:original_uri]=nil
        redirect_to(uri || admin_resources_path)
      else
        flash.now[:notice] = "Invalid user/password combination"
      end
    end
    
  end
 # alias_method :index,:login

  def index
    render :action => 'login'
  end
  
  # POST /login
  def create
     user = User.authenticate(params[:login], params[:password])
      if user
        session[:user_id] = user.id
	uri= session[:original_uri]
	session[:original_uri]=nil
        redirect_to(uri || admin_resources_path)
      else
        flash.now[:notice] = "Invalid user/password combination"
        render :action => "login" 
        #redirect_to(:action => "login")
      end
  end
  
  def logout
    session[:user_id] = nil
    flash[:notice] = "Logged out"
    redirect_to(:action => "login")
  end
  
  
end
