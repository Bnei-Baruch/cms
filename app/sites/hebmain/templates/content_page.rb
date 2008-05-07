class Hebmain::Templates::ContentPage < WidgetManager::Template

  def set_layout
    layout.ext_content = ext_content
    layout.ext_title = ext_title
    layout.ext_main_image = ext_main_image
    layout.ext_related_items = ext_related_items
  end
  
  def ext_content
    WidgetManager::Base.new do
      h1 get_title
      h2 get_small_title
      div(:class => 'descr') { text get_sub_title }
      div(:class => 'author') {
        span'תאריך: ' + get_date, :class => 'left' unless get_date.empty?
        unless get_writer.empty?
          span(:class => 'right') {
            text 'מאת: '
            unless get_writer_email.empty?
              a(:href => 'mailto:' + get_writer_email){
                img(:src => img_path('email.gif'), :alt => 'email')
                text ' ' + get_writer
              }
            else
              text ' ' + get_writer
            end
          }
        end
      }
      content_resources.each{|e|
        div(:class => 'item') {
          render_content_resource(e)
        } 
      }
    end
  end

  def ext_title
    WidgetManager::Base.new do
      text get_name
    end
  end
  
  def ext_meta_title
    WidgetManager::Base.new do
      text get_name# unless get_hide_name
    end
  end
  
  def ext_main_image
    WidgetManager::Base.new do
      div(:class => 'image'){
        img(:src => get_main_image, :alt => get_main_image_alt, :title => get_main_image_alt)
        text get_main_image_alt
      }
    end
  end
  
  def ext_related_items
    WidgetManager::Base.new do
      related_items.each{|e|
        render_related_item(e)
      }  
    end
  end
  
  private

  def render_content_resource(tree_node)
    class_name = tree_node.resource.resource_type.hrid
    w_class(class_name).new(:tree_node => tree_node).render_to(self)
  end
  
  def content_resources
    TreeNode.get_subtree(
    :parent => tree_node.id, 
    :resource_type_hrids => ['article'], 
    :depth => 1,
    :has_url => false
    )               
  end

  def render_related_item(tree_node)
    class_name = tree_node.resource.resource_type.hrid
    return w_class(class_name).new(:tree_node => tree_node, :view_mode => 'related_items').render_to(self)
  end
    
  def related_items
    TreeNode.get_subtree(
    :parent => tree_node.id, 
    :resource_type_hrids => ['box'], 
    :depth => 1,
    :has_url => false
    )               
  end
    
  
end