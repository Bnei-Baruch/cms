xml.instruct! :xml, :version=>"1.0"
xml.feed(:xmlns => "http://www.w3.org/2005/Atom") do
  xml.title(@presenter.website_node.resource.properties('title').get_value)
  xml.subtitle(@presenter.website_node.resource.properties('description').get_value)
  xml.id(@presenter.home + '/feed.atom')
  xml.link "href" => @presenter.home,
           "type" => "application/atom+xml",
           "rel"  => "self"
  xml.updated(@presenter.website_node.updated_at.iso8601)

  @pages.each do |entry|
    xml.entry do
      xml.id(get_page_url(entry))
      xml.title(entry.resource.properties('title').get_value)
      xml.content(entry.resource.properties('description').get_value, :type => 'text')
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