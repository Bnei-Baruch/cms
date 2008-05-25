class Hebmain::Widgets::ContentPage < WidgetManager::Base

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
    main_tree_node = tree_node.resource.tree_nodes.main
    w_class('cms_actions').new(:tree_node => tree_node, :options => {:buttons => %W{ delete_button edit_button }, :position => 'bottom'}).render_to(doc)
    h1 get_title unless get_title.empty?
    h2 get_small_title unless get_small_title.empty?
    div(:class => 'descr') { text get_description } unless get_description.empty?
    div(:class => 'author') {
      span'תאריך: ' + get_date, :class => 'right' unless get_date.empty?
      a(:class => 'left', :href => get_page_url(main_tree_node)) { text "לכתבה..." }
    }
    img(:src => @image_src, :alt => get_preview_image_alt, :title => get_preview_image_alt) if @image_src
  end

end
