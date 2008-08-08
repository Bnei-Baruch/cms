# General configuration - if no other configuration module found this is the last override file
module	Configuration::Global
  SETTINGS = {
    :site_dir => 'global', # define the view directory under app/views/sites/
    :language => 'english', # define the interface language 
    :site_direction => 'ltr',
    :short_language => 'en',
    :use_advanced_read_more => true
  }

end