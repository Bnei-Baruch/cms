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
        show_content_resources(:resources => site_update_entries)
      }
    }
  end
  
  def render_kabtv
    div(:class => 'tv_news_container'){
      w_class('cms_actions').new( :tree_node => tree_node,
        :options => {:buttons => %W{ new_button edit_button delete_button },
          :resource_types => %W{ site_updates_entry },
          :new_text => 'הוספת עדכונים',
          :has_url => false}).render_to(self)
      unless site_update_entries.empty?
        div(:class => 'box_headersection_tv'){text I18n.t(:newsonthechannel)}
        div(:class => 'entries'){
          make_sortable(:selector => ".tv_news_container .entries", :axis => 'y') {
            show_content_resources(:resources => site_update_entries,:sortable => 'true', :force_mode => 'tv', :first_item_mode => 'tvopen')
          }
        }
      end
    }
  end
  
  def render_full
    div(:class => 'news container'){
      w_class('cms_actions').new( :tree_node => tree_node,
        :options => {:buttons => %W{ new_button edit_button delete_button },
          :resource_types => %W{ site_updates_entry },
          :new_text => 'הוספת עדכונים',
          :has_url => false,
          :position => 'bottom'}).render_to(self)
    
      h3 get_title, :class => 'box_header'
      div(:class => 'entries'){
        make_sortable(:selector => ".news .entries", :axis => 'y') {
          show_content_resources(:resources => site_update_entries,
            :sortable => 'true',
            :force_mode => 'news')
        }
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
  
end
