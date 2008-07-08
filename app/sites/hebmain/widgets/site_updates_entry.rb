class Hebmain::Widgets::SiteUpdatesEntry < WidgetManager::Base
  
  def render_full
    div(:class => 'update'){
      
      w_class('cms_actions').new( :tree_node => tree_node, 
                                  :options => {:buttons => %W{ edit_button delete_button }, 
                                  :resource_types => %W{ site_updates_entry },
                                  :new_text => 'צור יחידת תוכן חדשה', 
                                  :has_url => false,
                                  :position => 'bottom'}).render_to(self)
 
      h4 get_title
      
      rawtext get_description
      div(:class => 'link'){
        url = get_url

        unless url.empty?
          a({:href => url, :title => 'link'}.merge!gg_analytics_tracking(get_url_text)) {
            rawtext get_url_text
            img(:src => img_path('arrow-left.gif'), :alt => '')
          }
        end
      }
    }
  end
  
  def gg_analytics_tracking (name_of_link = '')
	  if presenter.is_homepage? 
	  	{:onclick => 'javascript:urchinTracker(\'/homepage/news/'+name_of_link+'\');'}
  	  else
  	  	{}
  	  end
  end
  
  def render_news
    div(:class => 'item'){
      
      w_class('cms_actions').new( :tree_node => tree_node, 
                                  :options => {:buttons => %W{ edit_button delete_button }, 
                                  :resource_types => %W{ site_updates_entry },
                                  :new_text => 'צור יחידת תוכן חדשה', 
                                  :has_url => false,
                                  :position => 'bottom'}).render_to(self)
 
      h4 get_title
      
      rawtext get_description
      br
      div(:class => 'link'){
        url = get_url
        unless url.empty?
          a get_url_text, :href => url, :title => 'link'
        end
        div(:class => 'border'){rawtext('&nbsp;')}
      }
    }
  end
  
end