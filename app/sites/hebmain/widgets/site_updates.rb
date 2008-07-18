class Hebmain::Widgets::SiteUpdates < WidgetManager::Base
  
  def render_right
    div(:class => 'updates container'){
      w_class('cms_actions').new( :tree_node => tree_node, 
        :options => {:buttons => %W{ new_button edit_button delete_button }, 
          :resource_types => %W{ site_updates_entry },
          :new_text => 'הוספת עדכונים', 
          :has_url => false}).render_to(self)
    
      h3 get_title, :class => 'box_header'

      div(:class => 'entries'){
        show_update_entries(site_update_entries, 'full')
      }
    }
  end
  
  def render_full
    render_news
  end
  
  def render_news
    
    div(:class => 'news container'){
      w_class('cms_actions').new( :tree_node => tree_node, 
        :options => {:buttons => %W{ new_button edit_button delete_button }, 
          :resource_types => %W{ site_updates_entry },
          :new_text => 'הוספת עדכונים', 
          :has_url => false,
          :position => 'bottom'}).render_to(self)
    
      h3 get_title, :class => 'box_header'
    
      div(:class => 'entries'){
        show_update_entries(site_update_entries, 'news')
      }
    }
  end
  
  private
  
  def site_update_entries
    TreeNode.get_subtree(
      :parent => tree_node.id, 
      :resource_type_hrids => ['site_updates_entry'], 
      :depth => 1,
      :status => ['PUBLISHED', 'DRAFT'] 
    )               
  end    
  
  def show_update_entries (site_update_entries, view_mode)
    site_update_entries.each { |e|
      if e.resource.status == 'DRAFT'
        div(:class => 'draft') { render_content_resource(e, view_mode) }
      else
        render_content_resource(e, view_mode)
      end
    }
  end
end