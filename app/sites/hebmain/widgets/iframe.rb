class Hebmain::Widgets::Iframe < WidgetManager::Base

  def render_full
    w_class('cms_actions').new(:tree_node => tree_node, :options => {:buttons => %W{ delete_button  edit_button }}).render_to(self)
    url = get_url
    unless url.empty?
      title = get_title || ''
      height = get_height || 500
      height = "#{-height}%" if height < 0

      if tree_node.placeholder == 'related_items'
        div(:class => 'box all-box-background') {
          div(:class => 'box-top') { rawtext('&nbsp;') }
          div(:class => 'box-mid') {

            h4 get_title unless get_title.empty?

            rawtext <<-IFRAME
            <iframe name='iframe_#{tree_node.id}' class='iframe_no_border' src='#{url}' title='#{title}' width='100%' height='#{height.to_s}' #{get_add_params}></iframe>
            IFRAME
          }
          div(:class => 'box-bot') { rawtext('&nbsp;') }
        }
      else
        rawtext <<-IFRAME
            <iframe class='iframe_no_border' src='#{url}' title='#{title}' width='100%' height='#{height.to_s}' #{get_add_params}></iframe>
        IFRAME
      end

    end
  end

end
