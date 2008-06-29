class Hebmain::Widgets::Sitemap < WidgetManager::Base
  
  def render_full
 	div(:class => 'sitehead'){
  				text 'מפת האתר'
  			}
  	div(:class => 'sitemap'){
  			
  			presenter.main_sections.each {|section|
  			
  			if (section.resource.name == 'בלוגים')
  				debugger 
  			end
  				
  			
  			
  			div(:class => 'box'){
  			  	
  			  div(:class => 'title'){a section.resource.name, :href => get_page_url(section)}
  			  
  			 get_sub_section(section).each {|i|
			    div (:class => 'list'){
				  a i.resource.name, :href => get_page_url(i)
			    }
			  }
			  
			}
  		}
  		div(:class => 'clear') {text ' '}	
  	}
  end
  
  
  def get_sub_section (tree_node)
  	TreeNode.get_subtree (
  		:parent => tree_node.id, 
    	:resource_type_hrids => ['content_page',], 
    	:depth => 1,
    	:has_url => true,
    	:properties => 'b_hide_on_navigation = false')
  	
  end
  	
  
end