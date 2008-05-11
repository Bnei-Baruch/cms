class Hebmain::Widgets::Box < WidgetManager::Base
  
  def render_related_items
    div(:class => 'box') {
      div(:class => 'box-top'){rawtext('&nbsp;')}
      div(:class => 'box-mid'){
        h4 get_title unless get_title.empty?
        rawtext get_body
        br
        w_class('cms_actions').new(:tree_node => tree_node, :options => {:buttons => %W{ delete_button  edit_button }}).render_to(doc)
      }
      div(:class => 'box-bot'){rawtext('&nbsp;')}
    }
  end
  
end
