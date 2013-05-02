resource = @presenter.node.resource
rp = resource.properties('preview_image')
image_url = get_preview_image_url_by_resource_property(rp, 'medium') rescue img_path('logo.png')
home = @presenter.home
title = resource.properties('title').get_value
description = resource.properties('description').get_value
language = @site_settings[:short_language] || 'en'

xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title title
    xml.language language
    xml.description description
    xml.link home
    xml.image do
      xml.url   image_url
      xml.title title
      xml.link  home
    end
    @pages.each do |page|
      rp = page.resource.properties('preview_image')
      image_url = get_preview_image_url_by_resource_property(rp, 'medium')
      description = page.resource.properties('description').get_value
      description = description + '<p><img src=\'' + image_url + '\' /></p>' if image_url
      title = page.resource.properties('title').get_value
      
      xml.item do
        xml.title title
        xml.description description
        xml.pubDate page.created_at.rfc822 
        xml.link get_page_url(page)
      end
    end
  end
end