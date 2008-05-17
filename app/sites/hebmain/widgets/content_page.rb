class Hebmain::Widgets::ContentPage < WidgetManager::Base

  def render_full
    h1 get_title
    h2 get_small_title
    div(:class => 'descr') { text get_sub_title }
    div(:class => 'author') {
      span'תאריך: ' + get_date, :class => 'right' unless get_date.empty?
      a(:class => 'left') { text "...לכתבה" }
    }
    img(:src => get_main_image, :alt => get_main_image_alt, :title => get_main_image_alt)
  end

end
