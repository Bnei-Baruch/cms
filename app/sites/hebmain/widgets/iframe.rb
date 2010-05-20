class Hebmain::Widgets::Iframe < WidgetManager::Base
  
  def render_full
    w_class('cms_actions').new(:tree_node => tree_node, :options => {:buttons => %W{ delete_button  edit_button }}).render_to(self)
    url = get_url
    unless url.empty?
      title = get_title || ''
      height = get_height || 500
      rawtext <<-IFRAME
        <iframe class='iframe_no_border' src='#{url}' title='#{title}' width='100%' height='#{height.to_s}' #{get_add_params}></iframe>
      IFRAME
    end
  end
  
end
