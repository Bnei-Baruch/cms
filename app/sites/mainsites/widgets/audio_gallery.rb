class Mainsites::Widgets::AudioGallery < WidgetManager::Base

  def render_full
    audio_admin
    id = tree_node.object_id
    div(:class => 'playlist-player', :id => "id-#{id}") {
      div(:class => 'play-title') {
        rawtext tree_node.resource.properties('title').get_value
      }
      div(:id => "flashplayer-#{id}", :class => 'flashplayer') {
      }
      div(:class => 'play-serv'){}
      div(:id => "playlist-#{id}", :class => 'playlist'){
        ul{
          audio_items.each_with_index { |audio_item, index|
            li {
              a(:href => audio_item.resource.properties('url').get_value, :class => 'h1-play') {
                rawtext format('%02d. %s', index, audio_item.resource.properties('title').get_value)
              }
            }
          }
        }
      }
    }
  end

  private

  def audio_admin
    w_class('cms_actions').new( :tree_node => tree_node, 
      :options => {
        :buttons => %W{ new_button edit_button delete_button },
        :resource_types => %W{ audio },
        :new_text => _(:create_new_content_item),
        :has_url => false,
        :style => 'height:100px;'
      }).render_to(self)
  end
  
  def audio_items
    @audio_items ||= TreeNode.get_subtree(
      :parent => tree_node.id, 
      :resource_type_hrids => ['audio'],
      :depth => 1,
      :has_url => false,
      :status => ['PUBLISHED', 'DRAFT']
    )               
  end
  
end

