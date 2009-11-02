class Global::Widgets::ManpowerForm < WidgetManager::Base 
  def render_full 
    w_class('cms_actions').new(:tree_node => tree_node, :options => {:buttons => %W{ delete_button  edit_button }, :position => 'bottom'}).render_to(self)
    h3{text 'Not implemented.'}
  end
end
