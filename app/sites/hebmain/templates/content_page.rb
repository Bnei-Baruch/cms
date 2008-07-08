class Hebmain::Templates::ContentPage < WidgetManager::Template

  def set_layout
    layout.ext_content = ext_content
    layout.ext_title = ext_title
    layout.ext_description = ext_description
    layout.ext_main_image = ext_main_image
    layout.ext_related_items = ext_related_items
  end

  def ext_content
    WidgetManager::Base.new do
      w_class('cms_actions').new(:tree_node => @tree_node,
        :options => {:buttons => %W{ new_button edit_button },
                     :resource_types => %W{ article content_preview section_preview rss video media_rss video_gallery},
                     :button_text => 'ניהול דף תוכן',
                     :new_text => 'צור יחידת תוכן חדשה',
                     :edit_text => 'ערוך דף תוכן',
                     :has_url => false, :placeholder => 'main_content'}).render_to(self)
      unless get_acts_as_section
        h1 get_title
        small_title = get_small_title
        h2 get_small_title unless small_title.empty?
        sub_title = get_sub_title
        div(:class => 'descr') { text get_sub_title } unless sub_title.empty?
        my_date = get_date
        writer = get_writer
        unless my_date.empty? && writer.empty?
          div(:class => 'author') {
            span'תאריך: ' + my_date, :class => 'left' unless my_date.empty?
            unless writer.empty?
              span(:class => 'right') {
                text 'מאת: '
                unless get_writer_email.empty?
                  a(:href => 'mailto:' + get_writer_email){
                    img(:src => img_path('email.gif'), :alt => 'email')
                    text ' ' + writer
                  }
                else
                  text ' ' + writer
                end
              }
            end
          }
        end
      end
      unless get_body.empty?
        div(:class => 'item') {
          rawtext get_body
        }
      end
      content_resources.each{|e|
        div(:class => 'item') {
          render_content_resource(e)
          div(:class => 'clear')
        } 
      }
    end
  end

  def ext_title
    WidgetManager::Base.new do
      text get_name
    end
  end

  def ext_description
    WidgetManager::Base.new do
      text get_description
    end
  end

  def ext_meta_title
    WidgetManager::Base.new do
     #  text get_name# unless get_hide_name
     w_class('breadcrumbs').new(:view_mode => 'meta_title') 
    end
  end

  def ext_main_image
    WidgetManager::Base.new do
      if get_main_image && !get_main_image.empty?
        div(:class => 'image'){
          img(:src => get_main_image, :alt => get_main_image_alt, :title => get_main_image_alt)
          text get_main_image_alt
        }
      end                
    end
  end

  def ext_related_items
    WidgetManager::Base.new do
      w_class('cms_actions').new(:tree_node => @tree_node, :options => {:buttons => %W{ new_button }, :resource_types => %W{ box },:new_text => 'צור קופסא חדשה', :has_url => false, :placeholder => 'related_items', :position => 'bottom'}).render_to(self)
      related_items.each{|e|
        render_related_item(e)
      }  
    end
  end

  private

  def content_resources
    TreeNode.get_subtree(
      :parent => tree_node.id, 
      :resource_type_hrids => ['article', 'content_preview', 'section_preview', 'rss', 'video', 'media_rss', 'video_gallery'], 
      :depth => 1,
      :has_url => false,
      :placeholders => ['main_content'],
      :status => ['PUBLISHED', 'DRAFT']
    )               
  end

  def render_related_item(tree_node)
    class_name = tree_node.resource.resource_type.hrid
    return w_class(class_name).new(:tree_node => tree_node).render_to(self)
  end

  def related_items
    TreeNode.get_subtree(
      :parent => tree_node.id, 
      :resource_type_hrids => ['box'], 
      :depth => 1,
      :has_url => false,
      :placeholders => ['related_items'],
      :status => ['PUBLISHED', 'DRAFT']
    )               
  end


end