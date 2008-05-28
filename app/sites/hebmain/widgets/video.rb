class Hebmain::Widgets::Video < WidgetManager::Base
  
  def render_full
    # flowplayer
    # default flash, second wmv url 

    w_class('cms_actions').new( :tree_node => tree_node, 
      :options => {:buttons => %W{ edit_button delete_button }, 
        :resource_types => %W{ site_updates_entry },
        :new_text => 'צור יחידת תוכן חדשה', 
        :has_url => false
      }).render_to(self)
      h3(:class => 'video'){
        text get_title
      }
      div(:class => 'full-video') {
        description = get_description
        p { rawtext description if description }
        # div(:id => "flashplayer-#{tree_node.object_id}")
        div(:id=> "flashplayer-#{tree_node.object_id}", :class => 'flashplayer'){
          img(:width => "504", :height => "378", :border => "0", :src => "/splash.jpg")
          p(:class => "playbutton", :style => "margin-top: -140px;"){
            a{
              span 'Show me'
              b
            }
          }
        }
        javascript {
          rawtext <<-Player
          flashembed("flashplayer-#{tree_node.object_id}", {src:'/flowplayer/FlowPlayerLight.swf', width:504,  
          height:378,loadEvent: 'click'}, {config: {

              autoPlay: false,
              loop: false,
              videoFile: '#{get_flash_url}',
              initialScale: 'scale', 
              useNativeFullScreen: true,
              showStopButton:true,
              autoRewind:true,
              showVolumeSlider: false,
              controlsOverVideo: 'ease',
              controlBarBackgroundColor: -1,
              controlBarGloss: 'low',
              menuItems: [ 0, 0, 0, 0, 0, 1, 1 ],
//              splashImageFile: '/image.jpg',
//              usePlayOverlay:true,
//              overlay: '/playbutton.png',
              overlayId: 'flashplayer-#{tree_node.object_id} '
            }} 
          );
          Player
        }
        # image = get_preview_image
        # img(:src => image, :alt => 'player') if image
        
      }
  
      div(:class => 'embed'){
        # span(:class => 'text') {
        #   text '  Embed'
        # }
        # input(:id => 'addr', 
        #   :value =>'<object width="425" height=...',
        #   :readonly => 'readonly',
        #   :onclick => "javascript:document.getElementById('addr').focus();document.getElementById('addr').select()")
        # span(:class => 'services'){
        #   img(:src => "/images/hebmain/player/pipe.gif", :alt => "")
        #   a(:href => get_url, :title => 'arrow') {
        #     img(:src => '/images/hebmain/player/arrow.gif', :alt => 'arrow')          
        #   }
        #   img(:src => '/images/hebmain/player/pipe.gif', :alt => '')
        # 
        #   a(:href => '#', :title => 'email', :alt => 'email') {
        #     img(:src => '/images/hebmain/player/email.gif', :alt => 'email')          
        #   }
        # }
      }
  end
end


#object="id = "MediaPlayer", width = '180', height = '200',
#    classid = "CLSID:22D6F312-B0F6-11D0-94AB-0080C74C7E95",
#    codebase = "http://activex.microsoft.com/activex/controls/mplayer/en/nsmp2inf.cab#Version=5,1,52,701",
#    standby = "Loading MicrosoftÂ® WindowsÂ® Media Player components...",
#    type = "application/x-oleobject", :align => "middle") {
#      param(:name => "FileName", :value => get_url)
#      param(:name => "ShowStatusBar", :value => 'true')
#      param(:name => "DefaultFrame", :value => 'mainframe')
#      param(:name => "autostart", :value => 'false')
#      embed(:type => "application/x-mplayer2",
#      pluginspage = "http://www.microsoft.com/Windows/MediaPlayer/",
#      src = get_url,
#      autostart = "false",
#      align = "middle",
#      width = "176",
#      height = "144",
#      defaultframe = "rightFrame",
#      showstatusbar = "true") {}"
# 