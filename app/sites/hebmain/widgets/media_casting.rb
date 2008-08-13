class Hebmain::Widgets::MediaCasting < WidgetManager::Base
    
  def render_full
    w_class('cms_actions').new(:tree_node => tree_node, :options => {:buttons => %W{ delete_button  edit_button }, :position => 'bottom'}).render_to(doc) 
  	
    title = get_title
    url = get_url
	        
    div(:class => 'mediacasting'){
	
      a(:class => 'hide-player', :href => ''){
        img :src => '/images/delete.gif', :alt => '', :style => 'vertical-align:middle;'
        text 'הפסק'
      }
		 
      div(:class => 'toggle-media'){
        a(:href => url, :class => 'media'){
          text title
        }
      }
	  	 
      a(:class => 'show-player', :href => ''){
        text title
      }
	  		
    }
	    
  end

end
