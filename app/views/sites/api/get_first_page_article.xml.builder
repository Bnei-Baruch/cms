xml.instruct!
resource = @tree_node.resource
rp = resource.properties('preview_image')
image_name = 'medium'
image_object = Attachment.get_short_attachment(rp.id) rescue nil
if image_object
  image = get_file_url(image_object, image_name)
end
description = resource.get_resource_property_by_property_hrid('description')
body = resource.get_resource_property_by_property_hrid('body')
comments = @tree_node.comments
comments_size = comments ? comments.size : 0
xml.article {
  # xml.created_at(resource.created_at)
  xml.category_id(@tree_node.parent_id)
  xml.article_id(@tree_node.id)
  xml.updated_at(resource.updated_at)
  xml.title(resource.name)

  xml.description(description)
  xml.num_of_comments(comments_size)
  xml.image(image)
}