class Sites::Mainsites < Sites::Global

  # Used to show the main sections (environments) of the site
  def main_sections(depth = 1)
    @main_sections ||=
    TreeNode.get_subtree(
    :parent => website_node.id, 
    :resource_type_hrids => ['content_page'], 
    :depth => depth,
    :has_url => true,
    :properties => 'b_hide_on_navigation = false'
    )               
  end

  def main_section
     main_sections.include?(node) ? node : node.ancestors.detect{ |e| main_sections.include?(e) }
  end

end
