class Mainsites::Widgets::Banner < WidgetManager::Base


  def render_full
    descr = get_description.gsub(/<\/?[^>]*>/, "")
    div(:class => 'banner'){
      w_class('cms_actions').new(:tree_node => tree_node, :options => {:buttons => %W{ delete_button edit_button },
          :button_text => 'banner',
          :position => 'bottom'}).render_to(self)
      sort_handle

      a(:href=> get_link, :target => '_blank'){img :src => get_picture(:image_name => "thumb"), :alt => descr, :title => descr}
    }
  end
  alias_method :render_sidebar, :render_full

end
