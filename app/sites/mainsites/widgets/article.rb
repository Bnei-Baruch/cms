class Mainsites::Widgets::Article < WidgetManager::Base
    
  def render_full
    w_class('cms_actions').new(:tree_node => tree_node, :options => {:buttons => %W{ delete_button  edit_button }, :position => 'bottom'}).render_to(self)
    unless get_title.empty?
      if get_hide_content
        h3(:class => 'hide_content') do
          a(:class => 'x-plus') {
            rawtext '&plus;'
          }
          a get_title
        end
        div(:class => 'hidden x-data')  do
          rawtext get_body
        end
      else
        h3 get_title
        rawtext get_body
      end
    end

  end

end
