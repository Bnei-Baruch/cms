class Sites::Mainsites < Sites::Global

  # Used to show the main sections (environments) of the site
  def main_sections
    TreeNode.get_subtree(
    :parent => website_node.id, 
    :resource_type_hrids => ['content_page'], 
    :depth => 1,
    :has_url => true,
    :properties => {:hide_on_navigation => 'f'}
    )               
  end

  def main_section
    main_sections.include?(node) ? node : node.ancestors.detect{ |e| main_sections.include?(e) }
  end
  
  def parents(tree_node = node) # by default it will use the current node
    node.ancestors.select{ |e| e.resource.resource_type.hrid == 'content_page' }
  end

end
