class Hebmain::Widgets::Subscription < WidgetManager::Base
  
  def render_full
    w_class('cms_actions').new(:tree_node => tree_node, 
                               :options => {:buttons => %W{ delete_button  edit_button }, 
                                            :position => 'bottom'}).render_to(doc)
    rawtext get_description unless get_description.empty?  
  end

end
