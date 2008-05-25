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
        div(:id => "flashplayer-#{tree_node.object_id}")
        javascript {
        rawtext <<-Player
        flashembed("flashplayer-#{tree_node.object_id}", {src:'/flowplayer/FlowPlayerLight.swf', width:447,  
        height:340}, {config: {

            autoPlay: false,
            videoFile: '#{get_flash_url}',
            initialScale: 'scale', 
            useNativeFullScreen: true,
            showVolumeSlider: false,
            controlsOverVideo: 'ease',
            controlBarBackgroundColor: -1,
            controlBarGloss: 'low',
            menuItems: [ 0, 0, 0, 0, 0, 1, 1 ]
          }} 
        );
        Player
        # rawtext <<-Player
        #   var player_#{tree_node.object_id};
        #   writeSWF("flashplayer/info.xml", "flashplayer/skin.swf", player_#{tree_node.object_id}, "flashplayer-#{tree_node.object_id}");
        # Player
        }
        # image = get_preview_image
        # img(:src => image, :alt => 'player') if image
        
#        rawtext <<-code
#          <!-- include flashembed -->
#          <script type="text/javascript" src="/flash/flashembed.min.js"></script>
#
#          <script>
#          /*
#           * window.onload event occurs after all HTML elements have been loaded
#           * this is a good place to setup your Flash elements
#           */
#          window.onload = function() {  
#
#              /*
#               * flashembed places Flowplayer into HTML element 
#               * whose id="example" (see below this script tag)
#               */
#              flashembed("example", 
#
#                /*
#                 * second argument supplies standard Flash parameters.
#                 * basically these are all you want to modify
#                 * but you can see full list here
#                 */
#                {
#                   src:'/flash/FlowPlayerLight.swf',
#                   width:400,  
#                   height:300,
#                   bgcolor:'#ffffff'
#                },
#
#                /*
#                 * third argument is Flowplayer specific configuration
#                 * full list of options is given here
#                 */
#                {config: {   
#                   videoFile: '/flash/example.flv',
#                   initialScale: 'scale', 
#                   useNativeFullScreen: true
#
#                   // supply more options here by separating them with commas
#                }} 
#             );
#          }
#          </script>
#
#          <!-- this DIV is where your Flowplayer will be placed. it can be anywhere -->
#          <div id="example"></div>
#        code
      }
  
      div(:class => 'embed'){
        span(:class => 'text') {
          text '  Embed'
        }
        input(:id => 'addr', 
          :value =>'<object width="425" height=...',
          :readonly => 'readonly',
          :onclick => "javascript:document.getElementById('addr').focus();document.getElementById('addr').select()")
        span(:class => 'services'){
          img(:src => "/images/hebmain/player/pipe.gif", :alt => "")
          a(:href => get_url, :title => 'arrow') {
            img(:src => '/images/hebmain/player/arrow.gif', :alt => 'arrow')          
          }
          img(:src => '/images/hebmain/player/pipe.gif', :alt => '')

          a(:href => '#', :title => 'email', :alt => 'email') {
            img(:src => '/images/hebmain/player/email.gif', :alt => 'email')          
          }
        }
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