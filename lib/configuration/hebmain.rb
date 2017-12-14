# encoding: utf-8
# General configuration - if no other configuration module found this is the last override file
module	Configuration::Hebmain
  SETTINGS = {
    # define the site view directory under app/views/sites/
    :site_name => 'hebmain',
    # define the group view directory under app/views/sites/ -
    # this is an override after the content is not found in 'site_dir'
    :group_name => 'mainsites',
    :cache => {
      :disable_cache => false,
    },
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
      # Possible options:
      # icon - icon for header
      # style - style for the icon
      # box_title - text on top of a box (with blueish background)
      # subtitle - blue text beneath the box_title
      # action - url to post the subscription form
      # method - get/post
      # tracker - usl to use for Google Analytics
      # box_text_button - text on "Send" button
      # input_box_text - text inside input box
      :use => true,
      :icon => 'newsletter_default.gif',
      :box_title => 'הירשמו לניוזלטר השבועי',
      :action => 'https://ay351.infusionsoft.com/app/form/process/543ae8a2cc4332eed42c21173ff93abc',
      :method => 'post',
      :tracker => '/homepage/widget/newsletter/hebrew',
      :box_text_button => 'שלח',
      :input_box_text => ' הזינו דואר אלקטרוני',
      :style => 'height:34px;left:3px;position:absolute;top:-6px;width:27px;z-index:2;',
      17 => {
        :tracker => '/homepage/widget/newsletter/hebrew_homepage',
      },
      3040 => {
        # :action => 'http://ymlp.com/subscribe.php?YMLPID=gbbwwygmgee',
        :tracker => '/homepage/widget/newsletter/hebrew_tv',
        :icon => 'newsletter_tv.png',
      },
    },
    # define widgets that should not have bottom border
    :disable_bottom_border => ['title'],
    # define list of groups that have permission to edit list of courses
    :editors_of_list_of_courses => ['אתר בעברית - קמפוס - טופס הרשמה'],
    :googleAdd => {
      :use => true,
      :googleAddAdSenseService => 'ca-pub-9068547212525872',
      :slot => 'kab-co-il_top-banner_950x65',
    },
    :search_form => true,
    :single_logo => {
      :use => false,
      :image => 'ligdol/logo.png',
      :alt => _(:ligdoltv)
    },
    :sitemap => {
      :use => true,
    },
    :downloads => {
      :use => true,
    },
    :flowplayer => {
      :key => '#\@f0b2be6a10fb2019139'
    },
  }

end
