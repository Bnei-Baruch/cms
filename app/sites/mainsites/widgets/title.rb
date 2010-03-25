class Mainsites::Widgets::Title < WidgetManager::Base
  
  def render_full
    w_class('cms_actions').new(:tree_node => tree_node, :options => {:buttons => %W{ delete_button  edit_button }}).render_to(self)
    
    title = get_title
    url = get_url
    url_string = get_url_string
    style = get_gray_back ? 'h1_gray' : 'h1'
    
    div(:class => 'section_preview') {
      div(:class => style) {
        text title unless title.empty?
        unless url.empty?
          a(:class => 'cont', :href => url) {
            text url_string unless url_string.empty?
            img(:src => img_path('arrow-left.gif'), :alt => '', :style => 'width:7px;height:12px;')
          }
        end
        div(:class =>'h1-right')
        div(:class =>'h1-left')
      }
    }
  end
  
end
