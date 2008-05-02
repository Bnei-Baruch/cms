# Application configuration - defines all the application configuration. Any predefiend settings should be put here and NOT EMBEDDED INSIDE THE PROJECT FILES
module	Configuration::Application
  SETTINGS = {
 #define default anonymous login user for anonymous access
    :anonymous_login_user => {:username => 'Anonymous', :password => 'bli_kavana'},
# define the global settings module
    :global_dir => 'global', 
 # define the interface language
    :language => 'english',
    # :default_site => {:domain => 'http://www.kab.co.il', :prefix => 'epaper_heb'},
# List of all modules that will be registered on application init. 
# if you want your site config to be used you should load it
    :registered_config_modules => ['hebmain', 'mainsites'],

# Url Migration definitions 
	:url_migration_action => {:action_404 => '404', :action_301 => '301'}
  }

end