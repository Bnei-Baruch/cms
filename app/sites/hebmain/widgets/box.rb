class Hebmain::Widgets::Box < WidgetManager::Base
  
  def render_related_items
    hide_border = get_hide_border
    if !hide_border.empty? && hide_border
      no_border = '-no-border'
    else
      no_border = ''
    end
    div(:class => 'box') {
      div(:class => 'box-top' + no_border){rawtext('&nbsp;')}
      div(:class => 'box-mid' + no_border){
        h4 get_title unless get_title.empty?
        rawtext get_body
        br
        w_class('cms_actions').new(:tree_node => tree_node, :options => {:buttons => %W{ delete_button  edit_button }}).render_to(doc)
      }
      div(:class => 'box-bot' + no_border){rawtext('&nbsp;')}
    }
  end
  
end
