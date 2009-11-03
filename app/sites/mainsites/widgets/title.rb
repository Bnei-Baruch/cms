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
    title = @options[:title]
    if title.empty?
      w_class('cms_actions').new(:tree_node => @tree_node,
        :options => {:buttons => %W{ new_button },
          :resource_types => %W{title},
          :button_text => _(:create_new_box_header),
          :new_text => _(:create_new_box_header),
          :has_url => false,
          :placeholder => @options[:position]})
    else
      title = title[0]
      klass = @options[:position] == 'middle-box' ? 'mid-box-top' : 'side-box-top'
      div{
        w_class('cms_actions').new(:tree_node => title,
          :options => {:buttons => %W{ delete_button edit_button },
            :resource_types => %W{title},
            :button_text => _(:box_header),
            :has_url => false,
            :placeholder => @options[:position]}).render_to(self)
        div(:class => "#{klass}"){
          text title.resource.properties('title').get_value
          div(:class => 'left-ear')
          div(:class => 'right-ear')
        }
      }
    end

  end
end
