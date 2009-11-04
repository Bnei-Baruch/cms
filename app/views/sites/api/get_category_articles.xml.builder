xml.instruct!
xml.articles{
  for article in @articles
    resource = article.resource
    
    rp = resource.properties('preview_image')
    image_name = 'medium'
    image_object = Attachment.get_short_attachment(rp.id) rescue nil
    if image_object
      image = get_file_url(image_object, image_name)
    end
    description = resource.get_resource_property_by_property_hrid('description')
    # debugger
    xml.article {
      # xml.created_at(resource.created_at)
      xml.category_id(article.parent_id)
      xml.article_id(article.id)
      xml.title(resource.name)
      xml.description(description)
      xml.image(image)
    }
  end
}
