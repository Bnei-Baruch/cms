class Hebmain::Widgets::Link < WidgetManager::Base
  
  def render_full
    a get_name, :href => get_url, :alt => get_alt if resource
  end
  
  
  private

  def get_name
    resource.name rescue ''
  end
  
  def get_url
    resource.properties('url').value rescue ''
  end
  
  def get_alt
    resource.properties('alt').value rescue ''
  end
end
