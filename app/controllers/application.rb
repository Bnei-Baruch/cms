# Filters added to this controller apply to all controllers in the application. Likewise,
# all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  
  before_filter :activate_global_parms
  
  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_cms_session_id'

	def set_website_session(show_all_websites)
		if show_all_websites
			session[:website] = nil
		else
			website = Website.find(params[:website_id])
			session[:website] = website.id if website
    end
	end



#  private

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
         redirect_to(:controller => "login", :action => "login")
      end
    end
    
    
  end
      
  def activate_global_parms
    $session=session
  end
  
  def save_refferer_to_session
      session[:referer] = request.env["HTTP_REFERER"]
  end
end
