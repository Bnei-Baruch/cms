xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title @presenter.website_node.resource.properties('title').get_value
    xml.description @presenter.website_node.resource.properties('description').get_value
    xml.link @presenter.home

    for page in @pages
      xml.item do
        xml.title page.resource.properties('title').get_value
        xml.description page.resource.properties('description').get_value
        xml.pubDate page.created_at.rfc822 
        xml.link get_page_url(page)
      end
    end
  end
end