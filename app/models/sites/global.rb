class Sites::Global < Presenter::Base

  def website_resource
    @website.website_resource
  end

  def website_node
    website_resource.tree_nodes.main
  end                      
  
  def website_subtree
    TreeNode.get_subtree(website_resource.id)
  end

  def node
    if @permalink 
      TreeNode.find_by_permalink_and_has_url(@permalink, true) rescue nil
    else
      website_node
    end
  end
  
  def node_name
    node.resource.name
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

  def sitename
    @website.hrid
  end

  def home
    @website.domain + ':3000' + '/' + @website.prefix
  end
  
  # Used to show the main sections (environments) of the site
  # def main_sections
  #   result = website_node.children || nil
  #   
  #   if result
  #     result.select do |tree_node|
  #       tree_node.resource.resource_type ==
  #     end
  #   end
  # end

  def node_template_path
    template_path(node_resource_type.hrid, 'full')
  end

  def node_layout_path
    layout_path(node_resource_type.hrid)
  end

  def error_path(view_mode) # for example - view_mode = '404' or '500'
    template_path('error', view_mode)
  end

  def template_path(object, view_mode)
    if File.exists?("#{RAILS_ROOT}/app/views/sites/#{sitename}/templates/#{object}")
      "sites/#{sitename}/templates/#{object}/#{view_mode}"
    else
      "sites/global/templates/#{object}/#{view_mode}"
    end  
  end

  def layout_path(object)
    if File.exists?("#{RAILS_ROOT}/app/views/sites/#{sitename}/layouts/#{object}")
      "sites/#{sitename}/templates/#{object}"
    else
      "sites/global/layouts/#{object}"
    end  
  end

end