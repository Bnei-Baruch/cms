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
    w_class('cms_actions').new(:tree_node => tree_node, :options => {:buttons => %W{ delete_button edit_button }, :position => 'bottom'}).render_to(doc)
    h1 get_title unless get_title.empty?
    div(:class => 'descr') { rawtext get_description } unless get_description.empty?
    div(:class => 'author') {
      a(:class => 'left', :href => get_url) { 
        text get_url_text unless get_url_text.empty?  
      }
    }
    img(:class => 'img', :src => @image_src, :alt => '') if @image_src
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
    w_class('cms_actions').new(:tree_node => tree_node, :options => {:buttons => %W{ delete_button edit_button }, :position => 'bottom'}).render_to(doc)
   
    h3 get_title, :class => 'box_header'
    img(:src => @image_src, :alt => 'preview') if @image_src
    rawtext get_description unless get_description.empty?
  end
  
end
