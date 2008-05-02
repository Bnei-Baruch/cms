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

end
