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
    # define widgets that should not have bottom border
    :disable_bottom_border => ['title'],
    # Google Search
    :google_result_width => 520,
    :search_id => '011301558357120452512:ulicov2mspu',
    :forid => 'FORID:11',
    # Google analytics
    :ua => 'UA-548326-62',
  }
end