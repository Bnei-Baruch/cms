class Hebmain::Templates::ContentPage < WidgetManager::Template

  def set_layout
    layout.ext_content = ext_content
    layout.ext_title = ext_title
    layout.ext_main_image = ext_main_image
  end
  
  def ext_content
    WidgetManager::Base.new do
      h1 get_title
      h2 get_small_title
      div(:class => 'descr') { text get_sub_title }
      div(:class => 'author') {
        span'תאריך: ' + get_date, :class => 'left' if get_date
        span(:class => 'right') {
          text 'מאת:'
          a(:href => 'mailto:XX@yy.com'){
            img(:src => img_path('email.gif'), :alt => 'email')
            text get_writer
          }
        }
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
  
  def ext_main_image
    WidgetManager::Base.new do
      div(:class => 'image'){
        img(:src => get_main_image, :alt => get_main_image_alt, :title => get_main_image_alt)
        text get_main_image_alt
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
  
  def resource
    @resource ||= tree_node.resource rescue nil
  end
  
  def get_name
    resource.name
  end
  
  def get_title
    resource.properties('title').value rescue ''
  end
  
  def get_small_title
    resource.properties('small_title').value rescue ''
  end
  
  def get_sub_title
    resource.properties('sub_title').value rescue ''
  end
  
  def get_writer
    resource.properties('writer').value rescue ''
  end
  
  def get_main_image_alt
    resource.properties('main_image_alt').value rescue ''
  end
  
  def get_main_image
    rp = resource.properties('main_image')
    get_file_html_url(:attachment => rp.attachment) if rp
  end
  
  def get_date
    resource.properties('date').value.strftime('%d.%m.%Y') rescue nil
  end
  
  
end