class Hebmain::Widgets::Title < WidgetManager::Base
  
  def render_full
    w_class('cms_actions').new(:tree_node => tree_node, :options => {:buttons => %W{ delete_button  edit_button }}).render_to(doc)
    
    title = get_title
    url = get_url
    url_string = get_url_string
    list_value_id = tree_node.resource.properties('title_style').get_value
    style = ''
    if list_value_id 
      color =  ListValue.find(:first, :conditions => ["id = ?", list_value_id]).string_value
      style = 'h1'
      style = (style + '_' + color) unless color == 'blue'
    end
    
    div(:class => 'section_preview') {
      div(:class => style) {
        text title unless title.empty?
        unless url.empty?
          a(:class => 'cont', :href => url) {
            text url_string unless url_string.empty?
            img(:src => img_path('arrow-left.gif'), :alt => '')
          }
        end
        div(:class =>'h1-right')
        div(:class =>'h1-left')
      }
    }
  end
  
end
