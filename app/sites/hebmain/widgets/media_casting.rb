class Hebmain::Widgets::MediaCasting < WidgetManager::Base
    
  def render_full
  	 w_class('cms_actions').new(:tree_node => tree_node, :options => {:buttons => %W{ delete_button  edit_button }, :position => 'bottom'}).render_to(doc) 
  	
	title = get_title
	url = get_url
	filetype = url.split('.').reverse[0]
	id_unik = (rand(10)).to_s();
	id_unik += title;
	        
	div(:class => 'mediacasting'){
	
		 a(:class => 'hide-player', :href => ''){
			text 'הסתר נגן'	  
	  	 }
		 
	  	 div(:class => 'toggle-media'){
			a(:href => url, :class => 'media', :id => id_unik){
				text title
			}
		  }
	  	 
	  		
	  	  a(:class => 'show-player', :href => ''){
			text title
  		}
	  		
	}
	    
  end

end
