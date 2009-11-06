# General configuration - if no other configuration module found this is the last override file
module	Configuration::Rusmain
  SETTINGS = {
    # define the site view directory under app/sites/
    :site_name => 'rusmain', 
    # define the group view directory under app/sites/ -
    # this is an override after the content is not found in 'site_dir'
    :group_name => 'mainsites',
    # define the interface language (for the frontend). This is powered by a multilingual plugin
    :language => 'russian',
    :short_language => 'ru',
    :site_direction => 'ltr',
    :layout_map => { 'search' => 'content_page'},
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
    :google_result_width => 500,
    :search_id => '009476949152162131478:wnmluf-2cgm',
    :forid => 'FORID:10',
    # Google analytics
    :ua => 'UA-548326-5',
    # Don't show "to all articles" if no url in title of content preview
    :hide_no_articles => true,
  }

end