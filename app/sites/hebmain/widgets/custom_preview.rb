class Hebmain::Widgets::CustomPreview < WidgetManager::Base
 
  def render_large
    @image_src = get_preview_image(:image_name => 'large')
    show_content_page
  end

  def render_medium
    @image_src = get_preview_image(:image_name => 'medium')
    show_content_page
  end

  def render_small
    @image_src = get_preview_image(:image_name => 'small')
    show_content_page
  end

  def show_content_page
    w_class('cms_actions').new(:tree_node => tree_node, :options => {:buttons => %W{ delete_button edit_button }, :position => 'bottom'}).render_to(self)
    h1 get_title unless get_title.empty?
    div(:class => 'descr') { rawtext get_description } unless get_description.empty?
    div(:class => 'author') {
      a(:class => 'left', :href => get_url) { 
        text get_url_text unless get_url_text.empty?  
      }
    }
    img(:class => 'img', :src => @image_src, :alt => '') if @image_src
  end
  
  def render_full
    image_src = get_preview_image(:image_name => 'large')
    url = get_url
    url_name = url.split('/').reverse[0]

    div(:class => 'custom_preview'){
      w_class('cms_actions').new(:tree_node => tree_node, :options => {:buttons => %W{ delete_button edit_button }, :position => 'bottom'}).render_to(self)
   
      h1(:class => 'box_header'){
        a(:href => url) {
          img(:src => image_src, :alt => 'preview') if image_src
          text get_title if get_title
        }
      }
    
      rawtext get_description unless get_description.empty?
      a({:class => 'more', :href => url}.merge!(gg_analytics_tracking(url_name))) { text _(:read_more) }
      div(:class => 'clear')
    }
  end

  def render_large_main_format
    @image_src = get_preview_image(:image_name => 'large')
    show_content_page_main_format
  end

  def render_medium_main_format
    @image_src = get_preview_image(:image_name => 'medium')
    show_content_page_main_format
  end

  def render_small_main_format
    @image_src = get_preview_image(:image_name => 'small')
    show_content_page_main_format
  end

  def show_content_page_main_format
    w_class('cms_actions').new(:tree_node => tree_node, :options => {:buttons => %W{ delete_button edit_button }, :position => 'bottom'}).render_to(self)
   
    a(:href => get_url) {  
     h3 get_title, :class => 'box_header' if get_title      
     img(:src => @image_src, :alt => 'preview') if @image_src
    }
    
    rawtext get_description unless get_description.empty?
  end
  
  private
  def gg_analytics_tracking (name_of_link = '')
    {:onclick => "javascript:google_tracker('/homepage/#{name_of_link}');"}
  end
  
end
