class Hebmain::Widgets::Article < WidgetManager::Base
    
  def render_full
    w_class('cms_actions').new(:tree_node => tree_node, :options => {:buttons => %W{ delete_button  edit_button }, :position => 'bottom'}).render_to(doc)
    h3 get_title
    rawtext get_body 
  end

end
