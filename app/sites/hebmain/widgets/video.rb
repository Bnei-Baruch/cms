class Hebmain::Widgets::Video < WidgetManager::Base

  def video_admin  
    w_class('cms_actions').new( :tree_node => tree_node, 
      :options => {:buttons => %W{ edit_button delete_button }, 
        :resource_types => %W{ site_updates_entry },
        :new_text => 'צור יחידת תוכן חדשה', 
        :has_url => false
      }).render_to(self)
  end
  
  def render_full
    video_admin
    # flowplayer
    # default flash, second wmv url 

    show_title = get_show_title
    if show_title.nil?
      show_title = false
    end
    
    if (show_title)
      h3(:class => 'video'){
        text get_title
      }
    end
    div(:class => 'full-video') {
      id = tree_node.object_id
      image = get_image
      if (show_title)
        description = get_description
        p { rawtext description } if !description.empty?
      end
      div(:id => "flashplayer-#{id}",
        :onclick => "flashembed('flashplayer-#{id}',{src:'/flowplayer/FlowPlayerLight.swf', bgcolor:'#E5E5E4',width:504, height:378},{config: playerConfig})") {
        if image && !image.empty?
          img(:src => get_image, :alt => '', :class => 'flashplayer')
        else
          div(:class => 'flashplayer')
        end
        p(:class => "playbutton"){
          a{
            span 'לחצו לצפייה'
            b {rawtext '&nbsp;'}
          }
        }
      }
      javascript {
        rawtext <<-Player
          var playerConfig = {
              autoPlay: true,
              loop: false,
              videoFile: '#{get_flash_url}',
              initialScale: 'scale', 
              useNativeFullScreen: true,
              showStopButton:true,
              autoRewind:true,
              showVolumeSlider: true,
              controlsOverVideo: 'ease',
              controlBarBackgroundColor: -1,
              controlBarGloss: 'low',
              showMenu:false
          };
        Player
      }
    }
    
    div(:class => 'embed'){
      wmvpath = get_download_link
      unless wmvpath.empty? #replace with empty? and check
          img(:class => "elem", :src => "/images/download.png")
          a(:href => wmvpath){text I18n.t(:download)}
      end
        #I18n.t(:download)
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
#         }
      }
    end
  
    def render_video_list
      video_admin
      a(:href => get_flash_url) {
        img(:src => get_image(:image_name => 'thumb'), :alt => '', :class => 'flashplayer')
      }
      a(:href => get_flash_url, :class => 'h1-play') {
        text get_title
      }
      div(:class => 'descr-play') {text get_description}
      div(:class => 'clear')
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