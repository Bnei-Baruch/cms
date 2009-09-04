class Mainsites::Widgets::MediaCasting < WidgetManager::Base
    
  def render_full
    w_class('cms_actions').new(:tree_node => tree_node, :options => {:buttons => %W{ delete_button  edit_button }, :position => 'bottom'}).render_to(self)
  	
    title = get_title
    url = get_url
	        
    div(:class => 'mediacasting'){
	
      a(:class => 'hide-player', :href => '#'){
        img :src => '/images/delete.gif', :alt => '', :style => 'vertical-align:middle;'
        text _(:stop)
      }
      a(:class => 'media-download', :href => url){
        img :src => '/images/download.jpg', :alt => '', :style => 'vertical-align:middle;'
        text _(:download)
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
