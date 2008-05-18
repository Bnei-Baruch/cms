class Hebmain::Widgets::ContentPage < WidgetManager::Base

  def render_full
    main_tree_node = tree_node.resource.tree_nodes.main
    w_class('cms_actions').new(:tree_node => tree_node, :options => {:buttons => %W{ delete_button edit_button }, :position => 'bottom'}).render_to(doc)
    h1 get_title unless get_title.empty?
    h2 get_small_title unless get_small_title.empty?
    div(:class => 'descr') { text get_description } unless get_description.empty?
    div(:class => 'author') {
      span'תאריך: ' + get_date, :class => 'right' unless get_date.empty?
      a(:class => 'left', :href => get_page_url(main_tree_node)) { text "לכתבה..." }
    }
    if items_size = @options[:items_size]
      case items_size
      when 1
        image_src = get_preview_image(:image_name => 'large')
      when 2
        image_src = get_preview_image(:image_name => 'medium')
      when 3
        image_src = get_preview_image(:image_name => 'small')
      end
    else
      image_src = get_preview_image(:image_name => 'small')
    end
      img(:src => image_src, :alt => get_preview_image_alt, :title => get_preview_image_alt) if image_src
  end

end
