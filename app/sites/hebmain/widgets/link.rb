class Hebmain::Widgets::Link < WidgetManager::Base
  
  def render_full
    w_class('cms_actions').new(:tree_node => @tree_node,
      :options => {:buttons => %W{ edit_button delete_button },
        :mode => 'inline',
        :resource_types => %W{ link }}).render_to(self)
    a get_name, :href => get_url, :title => get_alt if resource
  end

  def render_with_image
    if resource
      w_class('cms_actions').new(:tree_node => @tree_node,
        :options => {:buttons => %W{ edit_button delete_button },
          :mode => 'inline',
          :resource_types => %W{ link }}).render_to(self)
      a(:href => get_url, :title => get_alt) {
        img(:src => img_path('link.gif'), :alt => '')
        text get_name
      }
    end
  end
  
end
