module I18n 
  class << self
    def default_translation(exception, locale, key, options)
      if MissingTranslationData === exception
        case key.class
        when String
          return key
        when Symbol
          return key.humanize
        end
        return key.to_s.humanize
        #raise exception
      end
    end  
  end
end

class Object
  def _(*args)
    trans = (self.class.to_s+'.'+args[0].to_s.underscore.gsub(' ', '_')).to_sym
    I18n.translate(trans)
  end
end

class NilClass
def empty?
  true
end
end

module ActiveRecord
class Migration
    
  class << self
    # Login before migration in order to update DB
    def migration_login
      msession = Hash.new
      username = $config_manager.appl_settings[:cron_manager_login_user][:username]
      password = $config_manager.appl_settings[:cron_manager_login_user][:password]
      user = User.authenticate(username, password)
      if user
        msession[:user_id] = user.id
        msession[:current_user_is_admin] = user.groups.find(:all, :conditions => {:groupname=>'Administrators'}).length
      else
        raise "Access denied for Rss Reader user."
      end
      Thread.current[:session] = msession
    end
      
  end
end
end
