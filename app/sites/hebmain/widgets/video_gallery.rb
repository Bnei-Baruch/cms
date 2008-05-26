class Hebmain::Widgets::VideoGallery < WidgetManager::Base
  
  def render_full

    w_class('cms_actions').new( :tree_node => tree_node, 
      :options => {:buttons => %W{ edit_button delete_button }, 
        :resource_types => %W{ site_updates_entry },
        :new_text => 'צור יחידת תוכן חדשה', 
        :has_url => false
      }).render_to(self)
    id = tree_node.object_id
    div(:class => 'player') {
      div(:id => "flashplayer-#{id}") {
        img(:src => img_path('player/player.jpg'), :alt => '', :class => 'flashplayer')
      }

      div(:id => "playlist-#{id}"){
        a 'מה היא קבלה?', :href => 'http://files.kab.co.il/files/heb_o_rav_2008-05-22_qa_bb_shal-et-ha-mekubal_lo-mistaderet-im-boss.flv'
        a 'האם הקבלה קשורה לדת?', :href => 'http://files.kab.co.il/files/eng_o_norav_2008-05-21_clip_bb_congress-sent-luis.flv'
        a 'למי מותר ללמוד קבלה?', :href => 'http://files.kab.co.il/files/rus_o_norav_2008-05-18_promo_bb_shavua-sefer-animazia.flv'
        a 'לשאלות נוספות...', :href => '#', :title => 'link', :class => 'more'
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
end

