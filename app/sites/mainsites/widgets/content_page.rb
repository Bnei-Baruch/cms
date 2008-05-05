
class Mainsites::Widgets::ContentPage < Widget::Base

  def resource
    externals && externals.has_key?(:tree_node) ? externals[:tree_node].resource : @presenter.node_resource
  end
  
  def main_image_alt
    @main_image_alt_rp ||= resource.properties('main_image_alt') # rp - resource_property
    @main_image_alt_rp ? @main_image_alt_rp.value : ''
  end
  
  def main_image
    @main_image_rp ||= @presenter.nrp('main_image')
    get_file_html_url(:attachment => @main_image_rp.attachment, :alt => main_image_alt) if @main_image_rp
  end
  
  def title
    @title_rp ||= @presenter.nrp('title')
    @title_rp ? @presenter.nrp('title').value : ''
  end

  def small_title
    @small_title_rp ||= @presenter.nrp('small_title')
    @small_title_rp ? @presenter.nrp('small_title').value : ''
  end

  def sub_title
    @sub_title_rp ||= @presenter.nrp('sub_title')
    @sub_title_rp ? @presenter.nrp('sub_title').value : ''
  end

  def writer
    @writer_rp ||= @presenter.nrp('writer')
    @writer_rp ? @presenter.nrp('writer').value : ''
  end
end
  
  
