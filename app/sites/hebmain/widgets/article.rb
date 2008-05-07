class Hebmain::Widgets::Article < WidgetManager::Base
    
  def render_full
    h3 get_title
    rawtext get_body 
  end

end
