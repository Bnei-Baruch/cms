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
    :site_direction => 'rtl'
  }

end