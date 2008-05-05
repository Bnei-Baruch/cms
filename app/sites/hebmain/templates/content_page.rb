class Hebmain::Templates::ContentPage < Widget::Base
  attr_accessor :layout, :resource, :tree_node
  def initialize(args_hash = {})
    super
    @tree_node = (args_hash.has_key?(:tree_node) ? args_hash[:tree_node] : presenter.node) rescue nil
    layout_class = args_hash[:layout_class] || nil
    @layout = layout_class.new(self)
    layout.ext_content = ext_content
    layout.ext_title = ext_title
    layout.ext_main_image = ext_main_image
  end

  def render
    layout.render_to(doc)
  end
  
  def ext_content
    Widget::Base.new do
      img(:src => get_main_image, :alt => get_main_image_alt, :title => '')
    end
  end
  
  def ext_title
    Widget::Base.new do
      text get_name
    end
  end
  def ext_main_image
    Widget::Base.new do
      div(:class => 'image'){
        img(:src => get_main_image, :alt => get_main_image_alt, :title => get_main_image_alt)
        text get_main_image_alt
      }
    end
  end
  
  private
  
  def resource
    @resource ||= tree_node.resource rescue nil
  end
  
  def get_name
    resource.name
  end
  
  def get_main_image_alt
    resource.properties('main_image_alt').value rescue ''
  end
  
  def get_main_image
    rp = resource.properties('main_image')
    get_file_html_url(:attachment => rp.attachment) if rp
  end
  
end