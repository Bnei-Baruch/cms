class Hebmain::Widgets::AudioGallery < WidgetManager::Base

# WORK IN PROGRESS, DO NOT USE IT  
  def render_full
    audio_admin
    id = tree_node.object_id
    div(:class => 'playlist-player', :id => id) {
      div(:class => 'play-title') {
        rawtext first_with_image.resource.properties('title').get_value if first_with_image
      }
      div(:id => "flashplayer-#{id}") {
      }
      div(:class => 'play-serv'){}
      div(:id => "playlist-#{id}", :class => 'playlist'){
        ul{
          audio_items.each { |audio_item|
            li {w_class('video').new(:tree_node => audio_item, :view_mode => 'audio_list').render_to(self)}
          }
        }
      }
      a get_url_text, :href => get_url, :title => 'link', :class => 'more' if get_url != ""
    }
  end

  private

  def audio_admin
    w_class('cms_actions').new( :tree_node => tree_node, 
      :options => {:buttons => %W{ new_button edit_button delete_button }, 
        :resource_types => %W{ audio },
        :new_text => 'צור יחידת תוכן חדשה', 
        :has_url => false
      }).render_to(self)
  end
  
  def audio_items
    @video_items ||= TreeNode.get_subtree(
      :parent => tree_node.id, 
      :resource_type_hrids => ['audio'], 
      :depth => 1,
      :has_url => false,
      :status => ['PUBLISHED', 'DRAFT']
    )               
  end
  
end

