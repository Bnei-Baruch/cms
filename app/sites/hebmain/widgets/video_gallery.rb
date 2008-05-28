class Hebmain::Widgets::VideoGallery < WidgetManager::Base
  
  def render_full
    render_homepage # Default
  end
  
  private
    
  def render_homepage

    w_class('cms_actions').new( :tree_node => tree_node, 
      :options => {:buttons => %W{ new_button edit_button delete_button }, 
        :resource_types => %W{ video },
        :new_text => 'צור יחידת תוכן חדשה', 
        :has_url => false
      }).render_to(self)
    id = tree_node.object_id
    div(:class => 'player') {
      div(:id => "flashplayer-#{id}") {
        img(:src => get_image, :alt => '', :class => 'flashplayer') if get_image
      }

      div(:id => "playlist-#{id}"){
        video_items.each { |video_item|
          a video_item.resource.properties('title').get_value, :href => video_item.resource.properties('flash_url').get_value 
        }
        a get_url_text, :href => get_url, :title => 'link', :class => 'more' if get_url
      }
    }
                
    javascript {
      rawtext <<-Player
        var playerConfig = { 
          autoPlay: true,
          loop: false,
          initialScale:'scale', 
          useNativeFullScreen: true,
          showStopButton:false,
          autoRewind:true,
          showVolumeSlider: false,
          showFullScreenButton:false,
          controlsOverVideo: 'ease',
          controlBarBackgroundColor: -1,
          controlBarGloss: 'low',
          showMenu:false
        };         
        Ext.onReady(function(){
          var flowplayer = null;
          var links = document.getElementById("playlist-#{id}").getElementsByTagName("a"); 
          for (var i = 0; i < links.length; i++) {
            if (links[i].getAttribute("class") == "more")
              continue;
            links[i].onclick = function() {
              playerConfig.videoFile = this.getAttribute("href");
              if (flowplayer == null) {
                flowplayer = flashembed("flashplayer-#{id}",  
                                        {src:"/flowplayer/FlowPlayerLight.swf", bgcolor:'#F0F4FD',width:226, height:169},  
                                        {config: playerConfig} 
                             );
              } else {     
                flowplayer.setConfig(playerConfig);
              }
              return false;
            }
          }
          document.getElementById("flashplayer-#{id}").onclick = function(){
            links[0].onclick(); 
          } 
        });
      Player
    }
  end
  
  def video_items
    TreeNode.get_subtree(
      :parent => tree_node.id, 
      :resource_type_hrids => ['video'], 
      :depth => 1,
      :has_url => false,
      :status => ['PUBLISHED', 'DRAFT']
    )               
  end
  
end

