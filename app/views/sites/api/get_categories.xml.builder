xml.instruct!
xml.categories{
  for category in @categories
    resource = category.resource
    
    rp = resource.properties('preview_image')
    image_name = 'medium'
    image_object = Attachment.get_short_attachment(rp.id) rescue nil
    if image_object
      image = get_file_url(image_object, image_name)
    end
    description = resource.get_resource_property_by_property_hrid('description')
    xml.category {
      # xml.created_at(resource.created_at)
      xml.category_id(category.id)
      xml.parent_id(category.parent_id)
      xml.name(resource.name)
      xml.description(description)
      xml.image(image)
    }
  end
}
