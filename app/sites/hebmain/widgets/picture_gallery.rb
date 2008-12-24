class Hebmain::Widgets::PictureGallery< WidgetManager::Base
    
  def render_full
   w_class('cms_actions').new( :tree_node => tree_node, 
    :options => {:buttons => %W{ new_button edit_button delete_button }, 
      :resource_types => %W{ image },
      :new_text => 'צור יחידת תוכן חדשה', 
      :has_url => false
    }).render_to(self)
  
    div(:class => 'picture_gallery'){
      h3{text get_title}
      div(:class => 'pictures'){
        pictures_list.each{|e|
        #  text e.resource.properties('path').get_value


          a(:href => get_file_html_url(:attachment => e.resource.properties('picture').attachment, :image_name => ''),
                                :class => 'gallery', 
                                :onclick => 'return hs.expand(this)'){
                        img(:src => get_file_html_url(:attachment => e.resource.properties('picture').attachment, :image_name => 'thumb'),
                                                      :alt => e.resource.properties('title').get_value,
                                                      :class => 'thumbnails')
          }
        }
      }
    }
  end

  def pictures_list
   TreeNode.get_subtree(
      :parent => tree_node.id, 
      :resource_type_hrids => ['image'], 
      :depth => 1
    )
end
  
  
  
end
