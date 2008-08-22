
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