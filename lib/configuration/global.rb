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
    :rss_items_limit => 10  # Number of items to show in RSS
  }
 
end