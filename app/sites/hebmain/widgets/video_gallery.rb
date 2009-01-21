class Hebmain::Widgets::VideoGallery < WidgetManager::Base
  
  def render_homepage
    video_admin
    id = tree_node.object_id
    div(:class => 'player', :id => "id-#{id}") {
      div(:id => "flashplayer-id-#{id}") {
        img(:src => get_image, :alt => '', :class => 'flashplayer') if get_image
      }

      div(:id => "playlist-#{id}", :class => 'playlist'){
        ol{
          video_items.each { |video_item|
            li {a video_item.resource.properties('title').get_value, :href => video_item.resource.properties('flash_url').get_value, :onclick => "javascript:pageTracker._trackPageview('/outbound/homepage/video/"+video_item.resource.properties('title').get_value+"');" }
          }
        }
      }
      a get_url_text, :href => get_url, :title => 'link', :class => 'more' if get_url
    }
  end
  
  def render_full
    video_admin
    id = tree_node.object_id
    first_with_image = video_items.detect { |item| item.resource.properties('image') }
    div(:class => 'inner-player', :id => id) {
      div(:class => 'play-title') {
        rawtext first_with_image.resource.properties('title').get_value if first_with_image
      }
      div(:id => "flashplayer-#{id}") {
        img(:src => get_file_html_url(:attachment => first_with_image.resource.properties('image').attachment,
            :image_name => 'myself'),
          :alt => '', :class => 'player-placeholder') if first_with_image
      }
      div(:class => 'play-serv'){}
      div(:id => "playlist-#{id}", :class => 'playlist'){
        ul{
          video_items.each { |video_item|
            li {w_class('video').new(:tree_node => video_item, :view_mode => 'video_list').render_to(self)}
          }
        }
      }
      a get_url_text, :href => get_url, :title => 'link', :class => 'more' if get_url != ""
    }
    p(:class => "play-list-button"){
        a{
          span 'לחצו לצפייה'
          b {rawtext '&nbsp;'}
        }
      }
  end

  private

  def video_admin
    w_class('cms_actions').new( :tree_node => tree_node, 
      :options => {:buttons => %W{ new_button edit_button delete_button }, 
        :resource_types => %W{ video },
        :new_text => 'צור יחידת תוכן חדשה', 
        :has_url => false
      }).render_to(self)
  end
  
  def video_items
    @video_items ||= TreeNode.get_subtree(
      :parent => tree_node.id, 
      :resource_type_hrids => ['video'], 
      :depth => 1,
      :has_url => false,
      :status => ['PUBLISHED', 'DRAFT']
    )               
  end
  
end

