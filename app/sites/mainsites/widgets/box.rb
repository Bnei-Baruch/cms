class Mainsites::Widgets::Box < WidgetManager::Base
  
  def render_related_items
    show_background = get_add_background
    background = ''
    unless show_background.is_a?(String) && show_background.empty?
      background = ' box-background' if show_background
    end
    
    no_border = ''
    if background.empty?
      hide_border = get_hide_border
      unless hide_border.is_a?(String) && hide_border.empty?
        no_border = '-no-border' if hide_border
      end
    end
    
    div(:class => 'box all-box-background') {
      div(:class => 'box-top' + no_border + background){rawtext('&nbsp;')} 
      div(:class => 'box-mid' + no_border + background){
        
        h4 get_title unless get_title.empty?
        if (background != '')
          div(:class => 'separator') { rawtext('&nbsp;') }
        end
        rawtext get_body
        br
        w_class('cms_actions').new(:tree_node => tree_node, :options => {:buttons => %W{ delete_button  edit_button }}).render_to(self)
      }
      div(:class => 'box-bot' + no_border + background){rawtext('&nbsp;')}
    }
  end
  
end
