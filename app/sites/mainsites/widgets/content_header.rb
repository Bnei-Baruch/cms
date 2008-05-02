class Mainsites::Widgets::ContentHeader < Widget::Base
  def external_sections
    TreeNode.get_subtree(
    :parent => @presenter.website_node.id, 
    :resource_type_hrids => ['link'], 
    :depth => 1,
    :has_url => false
    )               
  end
end
