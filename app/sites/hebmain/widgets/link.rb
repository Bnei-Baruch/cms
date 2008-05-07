class Hebmain::Widgets::Link < WidgetManager::Base
  
  def render_full
    a get_name, :href => get_url, :title => get_alt if resource
  end
  
end
