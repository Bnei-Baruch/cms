class Hebmain::Widgets::Link < WidgetManager::Base
  
  def render_full
    a get_name, :href => get_url, :title => get_alt if resource
  end

  def render_with_image
    if resource
      a(:href => get_url, :title => get_alt) {
        img(:src => img_path('link.gif'), :alt => '')
        text get_name
      }
    end
  end
  
end
