class Hebmain::Widgets::Banner < WidgetManager::Base


  def render_full
    w_class('cms_actions').new(:tree_node => tree_node, :options => {:buttons => %W{ delete_button edit_button}, :position => 'bottom'}).render_to(self)
    a(:href=> get_link, :target => "_blank"){img :src => get_picture(:image_name => "thumb"), :alt => get_description}
  end

end