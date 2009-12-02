# General configuration - if no other configuration module found this is the last override file
module	Configuration::Hebmain
  SETTINGS = {
    # define the site view directory under app/views/sites/
    :site_name => 'hebmain', 
    # define the group view directory under app/views/sites/ -
    # this is an override after the content is not found in 'site_dir'
    :group_name => 'mainsites',
    # define the interface language (for the frontend). This is powered by a multilingual plugin
    :language => 'hebrew',
    :short_language => 'he',
    :site_direction => 'rtl',
    # Map specific resource to custom layuot
    # <resource_type> => <layout_name>
    :layout_map => { 
      'search' => 'content_page'
    },
    # define view modes per parent widget and placeholder.
    :google_analytics => {
      :profile_key => "UA-548326-62",
      :new_version => false
    },
    :view_modes => {
      # parent widget
      :website => {
        # placeholder
        :home_kabtv => {
          :kabtv => 'homepage'
        },
        :left => {
          :media_rss => 'left',
          :rss => 'preview'
        },
        :right => {
          :video_gallery => 'homepage',
          :render_right => 'right'
        }
      },  
      # parent widget
      :content_page => {
        # placeholder
        :related_items => {
          :box => 'related_items',
          :rss => 'preview'
        }
      }
    },
    :newsletters => {
      :icon => 'newsletter_default.gif',
      :box_title => 'הרשמו לניוזלטר השבועי',
      :box_name => '',
      :action => 'http://ymlp.com/subscribe.php?YMLPID=gbbwwygmgeh',
      :method => 'post',
      :tracker => '/homepage/widget/newsletter/hebrew',
      :box_text_button => 'שלח',
      :input_box_text => ' הזינו דואר אלקטרוני',
      :style => 'height:40px;left:5px;position:absolute;top:-6px;width:32px;z-index:2;',
      17 => {
        :tracker => '/homepage/widget/newsletter/hebrew_homepage',
        :style => 'left:10px;position:absolute;top:1px;z-index:2;',
      },
      3040 => {
        :action => 'http://ymlp.com/subscribe.php?YMLPID=gbbwwygmgee',
        :tracker => '/homepage/widget/newsletter/hebrew_tv',
        :icon => 'newsletter_tv.png',
      },
    },
    # define widgets that should not have bottom border
    :disable_bottom_border => ['title']
  }

end