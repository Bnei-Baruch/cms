xml.instruct!
resource = @tree_node.resource
rp = resource.properties('preview_image')
image_name = 'medium'
image_object = Attachment.get_short_attachment(rp.id) rescue nil
if image_object
  image = get_file_url(image_object, image_name)
end
description = resource.get_resource_property_by_property_hrid('description') rescue ''
author = resource.get_resource_property_by_property_hrid('writer') rescue ''
body = resource.get_resource_property_by_property_hrid('body')
comments = @tree_node.comments
comments_size = comments ? comments.size : 0
xml.article {
  xml.category_id(@tree_node.parent_id)
  xml.article_id(@tree_node.id)
  xml.updated_at(resource.updated_at)
  xml.author(author)
  xml.title(resource.name)
  xml.short(description)
  xml.body(body)
  xml.num_of_comments(comments_size.to_s)
  xml.image(image)
}
