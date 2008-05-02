class Mainsites::Widgets::Link < Widget::Base
  def resource
    externals[:tree_node].resource rescue nil
  end

  def url
  	resource.properties('url').value
  end

  def alt
    resource.properties('alt').value
  end
end