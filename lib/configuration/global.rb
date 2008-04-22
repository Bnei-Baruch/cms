# General configuration - if no other configuration module found this is the last override file
module	Configuration::Global
  SETTINGS = {
    :site_dir => 'global', # define the view directory under app/views/sites/
    :language => 'english' # define the interface language
  }

end