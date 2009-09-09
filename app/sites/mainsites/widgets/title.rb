class Mainsites::Widgets::Title < WidgetManager::Base
  
  def render_inner_page
    title = @options[:title][0] rescue return
    div(:class => 'inner-title'){
      w_class('cms_actions').new(:tree_node => tree_node, :options => {:buttons => %W{ edit_button }}).render_to(self)
      text title.resource.properties('title').get_value
    }
  end
  
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
            img(:src => img_path('arrow-left.gif'), :alt => '')
          }
        end
        div(:class =>'h1-right')
        div(:class =>'h1-left')
      }
    }
  end

  def render_box_top
    title = @options[:title][0] rescue return
    klass = @options[:position] == 'middle-box' ? 'mid-box-top' : 'side-box-top'
    div{
      w_class('cms_actions').new(:tree_node => tree_node, :options => {:buttons => %W{ delete_button  edit_button }}).render_to(self)
      div(:class => "#{klass}"){
        text title.resource.properties('title').get_value
        div(:class => 'left-ear')
        div(:class => 'right-ear')
      }
    }
    
  end
end
