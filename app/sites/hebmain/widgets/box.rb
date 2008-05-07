class Hebmain::Widgets::Box < WidgetManager::Base
  
  def render_related_items
    div(:class => 'box') {
      div(:class => 'box-top'){rawtext('&nbsp;')}
      div(:class => 'box-mid'){
        h4 get_title unless get_title.empty?
        rawtext get_body
      }
      div(:class => 'box-bot'){rawtext('&nbsp;')}
    }
  end
  
end
