xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title @presenter.node.resource.properties('title').get_value
    xml.description @presenter.node.resource.properties('description').get_value
    xml.link @presenter.home
    image_url = get_file_url(@presenter.node.resource.properties('preview_image').attachment, 'small') rescue img_path('logo.png')
    xml.image do
      xml.url   image_url
      xml.title @presenter.node.resource.properties('title').get_value
      xml.link  @presenter.home
    end

    for page in @pages
      xml.item do
        xml.title page.resource.properties('title').get_value
        image_url = get_file_url(page.resource.properties('preview_image').attachment, 'small') rescue nil
        description = page.resource.properties('description').get_value
        description = description + '<p><img src=' + image_url + '/></p>' unless image_url.empty?
        xml.description description
        xml.pubDate page.created_at.rfc822 
        xml.link get_page_url(page)
      end
    end
  end
end