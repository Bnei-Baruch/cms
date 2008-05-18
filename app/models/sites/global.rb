class Sites::Global < Presenter::Base
  
  def port
    my_port = @controller.request.server_port.to_s
    my_port == '80' ? '' : ':' + my_port
  end
  
  def domain
    @full_domain ||= @controller.website.domain + port
  end
  
  def website_resource
    @website.website_resource
  end

  def website_node
    website_resource.tree_nodes.main rescue nil
  end                      
  
  def website_subtree
    TreeNode.get_subtree(:parent => website_resource.id)
  end

  def node
    if @permalink 
      # debugger
      TreeNode.find_by_permalink_and_has_url(@permalink, true) rescue nil
    else
      website_node
    end
  end
  
  def node_name
    node.resource.name
  end
  
  def node_resource
    node.resource
  end
  
  def node_type
    node_resource_type.name
  end
  
  def node_resource_type 
    node.resource.resource_type
  end
  
  def node_resource_properties(property = nil)
    node.resource.properties(property)
  end

  # Alias for node_resource_properties method for shorter name
  def nrp(property = nil)
    node_resource_properties(property)
  end
  
  def site_name
    @controller.site_name
  end

  def group_name
    @controller.group_name
  end

  def home
    prefix = ''
    prefix = '/' + @website.prefix unless @website.use_homepage_without_prefix
    domain + prefix
  end
  

  def node_template_path
    template_path(node_resource_type.hrid, 'full')
  end

  def node_layout_path
    layout_path(node_resource_type.hrid)
  end

  def error_path(view_mode) # for example - view_mode = '404' or '500'
    template_path('error', view_mode)
  end

  def template_path(resource, view_mode)
    @controller.template_path(resource, view_mode)
  end

  def layout_path(resource)
    @controller.layout_path(resource)
  end

  def widget_path(resource)
    @controller.widget_path(resource)
  end

  def w_class(resource)
    @controller.w_class(resource)
  end
    

end