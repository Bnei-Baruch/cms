class Sites::Mainsites < Sites::Global

  # Used to show the main sections (environments) of the site
  def main_sections
    # content_page = ResourceType.get_resource_type_by_hrid('content_page')
    TreeNode.get_subtree(
    :parent => website_node.id, 
    :resource_type_hrids => ['content_page'], 
    :depth => 1,
    :has_url => true,
    :properties => {:hide_on_navigation => 'f'}
    )               
    # , 
  end
  
end
