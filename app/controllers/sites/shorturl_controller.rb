require 'uri'

class Sites::ShorturlController < ApplicationController

  attr_reader :website
  attr_reader :tree_node
  
  # Add the 'app/sites' path of sites which is used by the application instead of regular 'app/views' folder
  custom_view_path = "#{RAILS_ROOT}/app/sites"
  self.prepend_view_path(custom_view_path)
  
  def json(id = params[:node])
    respond_to do |format|
    end
  end
  
  
  # This is the action that renders the view and responds to client
  def shorturl                          
    host = 'http://' + request.host
    prefix = params[:prefix]
    node = params[:id]
    query_string = request.query_string
    query_string = '?' + query_string unless query_string.empty?
        
    @node = TreeNode.find(:first, :conditions => ['id = ?', node])
    
    unless @node
      status_404
      return
    end
    
    my_port = request.server_port.to_s
    portinurl = my_port == '80' ? '' : ':' + my_port
    
    namedurl = host + portinurl + '/' + prefix + '/' + @node.permalink rescue ''
    
    if @node.has_url && @node.can_read?
      redirect_301(URI.escape(namedurl + query_string))
    else
      redirect_301(URI.escape(host + portinurl + '/' + prefix + '/' + query_string))
    end
    

  end
  

  def redirect_301(url)
    headers["Status"] = '301 Moved Permanently'
    redirect_to url
  end

  def status_404
    # render_widget :type => 'template', :widget => 'status', :view_mode => 'status404', :layout => false
    head_status_404
  end
  
  def head_status_404
    render :file => 'public/404.html', :status => 404
  end
  
  
end
