class Mainsites::Widgets::Article < WidgetManager::Base
    
  def render_full
    w_class('cms_actions').new(:tree_node => tree_node, :options => {:buttons => %W{ delete_button  edit_button }, :position => 'bottom'}).render_to(self)

    title = get_title
    body = get_body

    if title.empty?
      rawtext body
    else
      if get_hide_content
        h3(:class => 'hide_content') do
          a(:class => 'x-plus') {
            rawtext '&plus;'
          }
          a title
        end
        div(:class => 'hidden x-data')  do
          rawtext body
        end
      else
        h3 title
        rawtext body
      end
    end

  end

end
