class Mainsites::Widgets::Image < WidgetManager::Base
  
  def render_full
    text 'image'
  end

  def render_banner
    img :src => get_picture, :class => 'banner'
  end

end
