# Application configuration - defines all the application configuration. Any predefiend settings should be put here and NOT EMBEDDED INSIDE THE PROJECT FILES
module	Configuration::Application
  SETTINGS = {
 #define default anonymous login user for anonymous access
    :anonymous_login_user => {:username => 'Anonymous', :password => 'bli_kavana'},
# define the global settings module
    :global_dir => 'global', 
 # define the interface language
    :language => 'english',
# List of all modules that will be registered on application init. 
# if you want your site config to be used you should load it
    :registered_config_modules => ['hebmain', 'mainsites'] 
  }

end