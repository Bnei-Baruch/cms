# Configuration Manager - This is a configuration reader. The interface for reading configuration settings
# It can be used as an instance object for site configuration or 
class	Configuration::ConfigurationManager
  
  def initialize  
    @appl_settings = load_appl_settings
    @general_settings = load_general_settings
    @site_settings_cache = {}
  end

  # Returns a hash with all application settings
  def appl_settings
    @appl_settings
  end             
  
  # Returns a unified hash with settings for the site.
  def site_settings(site = nil)
    site_sym = site.to_sym
    @site_settings_cache[site_sym] if site && @site_settings_cache[site_sym]
    
    if site && @general_settings[site_sym]
      site_obj =  @general_settings[site_sym]
      group_dir = site_obj[:group_dir]
      if group_dir
        group = @general_settings[group_dir.to_sym] || {}
        result = @general_settings[:global].merge(group).merge(site_obj)
      else
        result = @general_settings[:global].merge(site_obj)
      end
      @site_settings_cache[site_sym] ||= result
      return result
    else
      nil
    end
  end
                                                               
  # Returns a specific setting for the site
  def get_site_setting(site, setting = nil)
    if setting && site_settings(site) && site_settings(site)[setting.to_sym]
      site_settings(site)[setting.to_sym]
    else                                  
      nil
    end
  end
  
  
  private
  # Returns the application settings
  def load_appl_settings
    Configuration::Application::SETTINGS
  end

  # Returns the registered site settings array.
  def sites_to_load
    @appl_settings[:registered_config_modules]
  end

  # Initializes the settings onto one hash with all registered settings.
  # Registered settings are defined in sites_to_load function which uses 
  # a particular application setting: "registered_config_modules"
  def load_general_settings
    settings = {}
    sites_to_load.each do |site|
      site_object = eval "Configuration::#{site.camelize}::SETTINGS"
      site_settings = {site.to_sym => site_object}
      settings.merge!(site_settings)
    end
    global_object = eval "Configuration::#{global_name.camelize}::SETTINGS"
    settings.merge({:global => global_object})
  end

  # Returns the defined global directory in app/views/sites/
  def global_name
    @appl_settings[:global_dir]
  end
  
end