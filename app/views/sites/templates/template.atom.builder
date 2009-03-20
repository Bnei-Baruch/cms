xml.instruct! :xml, :version=>"1.0"
xml.feed(:xmlns => "http://www.w3.org/2005/Atom") do
  xml.title(@presenter.node.resource.properties('title').get_value)
  xml.subtitle(@presenter.node.resource.properties('description').get_value)
  xml.id(@presenter.home + '/feed.atom')
  xml.link "href" => @presenter.home,
           "type" => "application/atom+xml",
           "rel"  => "self"
  xml.updated(@presenter.website_node.updated_at.iso8601)
  image_url = get_file_url(@presenter.node.resource.properties('preview_image').attachment, 'small') rescue img_path('logo.png')
  xml.logo image_url

  @pages.each do |entry|
    xml.entry do
      xml.id(get_page_url(entry))
      xml.title(entry.resource.properties('title').get_value)
      image_url = get_file_url(entry.resource.properties('preview_image').attachment, 'small') rescue nil
      description = entry.resource.properties('description').get_value
      description = description + '<p><img src=' + image_url + '/></p>' unless image_url.empty?
      xml.content(description, :type => 'html')
      xml.updated(entry.created_at.iso8601)
      xml.link "href" => get_page_url(entry),
               "type" => "text/html",
               "rel"  => "alternate"
      xml.author do
        xml.name "admin@kabbalah.info"
      end
    end
  end
end