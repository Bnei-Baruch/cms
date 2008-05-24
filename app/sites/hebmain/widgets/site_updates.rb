class Hebmain::Widgets::SiteUpdates < WidgetManager::Base
  
  def render_full
    
    div(:class => 'updates'){
      w_class('cms_actions').new( :tree_node => tree_node, 
                                  :options => {:buttons => %W{ new_button edit_button delete_button }, 
                                  :resource_types => %W{ site_updates_entry },
                                  :new_text => 'הוספת עדכונים', 
                                  :has_url => false}).render_to(self)
    
      h3 get_title, :class => 'box_header'
    
      site_update_entries.each do |site_update_entry|
        render_content_resource(site_update_entry)
      end
    }
  end
  
  def render_news
    
    div(:class => 'news'){
      w_class('cms_actions').new( :tree_node => tree_node, 
                                  :options => {:buttons => %W{ new_button edit_button delete_button }, 
                                  :resource_types => %W{ site_updates_entry },
                                  :new_text => 'הוספת עדכונים', 
                                  :has_url => false,
                                  :position => 'bottom'}).render_to(self)
    
      h3 get_title, :class => 'box_header'
    
      site_update_entries.each do |site_update_entry|
        render_content_resource(site_update_entry, 'news')
      end
    }
  end
  
  private
  
  def site_update_entries
    TreeNode.get_subtree(
      :parent => tree_node.id, 
      :resource_type_hrids => ['site_updates_entry'], 
      :depth => 1 
    )               
  end    
  
end