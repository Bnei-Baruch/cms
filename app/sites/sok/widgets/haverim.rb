class Sok::Widgets::Haverim < WidgetManager::Base

  def render_full
    div(:id => 'haverim', :style => "background-image:url('#{get_background}')") {
#      cms_action
      h1 _(:broadcast_yourself)
      p {rawtext _(:please_type_in_your_name_and_place_and_click_ok)}
      rawtext get_my_picture
#      p {rawtext _(:see_haverim)}
      rawtext get_haverim
    }
  end

  private

  def cms_action
    w_class('cms_actions').new(
      :tree_node => tree_node,
      :options => {
        :button_text => _(:edit_haverim_widget),
        :buttons => %W{ delete_button  edit_button }
      }).render_to(self)
  end
end
