class Mainsites::Widgets::Banner < WidgetManager::Base

  def render_full
    w_class('cms_actions').new(:tree_node => tree_node, :options => {:buttons => %W{ delete_button edit_button}, :position => 'bottom'}).render_to(self)
    link = get_link
    a_options = { :href => link, :onclick => "_gaq.push(['_trackEvent', 'banner click', '#{get_event_name}']);" }
    a_options[:class] = 'target_blank' unless get_internal_link
    image, dims = get_picture(:image_name => image_name, :with_dimensions => true)
    klass = ''

    if dims[0] == 0
			style = ""
			src = image
		else
      if get_hover == true
        dims[1] /= 2
        klass = 'hover'
      end

			style = "width:#{dims[0]}px;height:#{dims[1]}px;background:0 0 url(#{image}) no-repeat;"
			src = img_path('empty.gif')
		end

    a(a_options){img :src => src, :alt => get_description, :style => style, :class => klass}
  end

  private

  # There is a different column width on the homepage and inner pages,
  # but the same banner should be shown in both places. So we created a dedicated geometry:
  # thumb:240>;thumb_inner:178>;
  def image_name
    @presenter.is_homepage? ? 'thumb' : 'thumb_inner'
  end

  def name
    @name ||= get_name
  end
end
