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
    show_content_page(false)
  end

  def show_content_page(display_h2 = true)
    main_tree_node = tree_node.resource.tree_nodes.main
    w_class('cms_actions').new(:tree_node => tree_node, :options => {:buttons => %W{ delete_button edit_button }, :position => 'bottom'}).render_to(doc)
    img(:class => 'img', :src => @image_src, :alt => get_preview_image_alt, :title => get_preview_image_alt) if @image_src
    h1 get_title unless get_title.empty?
    h2 get_small_title if display_h2 && !get_small_title.empty?
    div(:class => 'descr') { text get_description } unless get_description.empty?
    a(:class => 'more', :href => get_page_url(main_tree_node)) { text "לכתבה..." }
  end

end
