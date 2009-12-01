# General configuration - if no other configuration module found this is the last override file
module	Configuration::Global
  SETTINGS = {
    :site_dir => 'global', # define the view directory under app/views/sites/
    :language => 'english', # define the interface language 
    :site_direction => 'ltr',
    :short_language => 'en',
    :cache => {
      :disable_cache => false,
    },
    :use_advanced_read_more => true,
    :comments => {
      :enable_site_wide => true
    },
    :google_analytics => {
      :profile_key => nil,
      :new_version => false
    },
    :page404_permalink => 404, #permalink of 404 page
    :rss_items_limit => 10,  # Number of items to show in RSS
    :chain_meta_title => false  # This configuration determines whether to chain the whole path to root in meta title or not. 
  }
 
end