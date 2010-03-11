module I18n 
  class << self
    def default_translation(exception, locale, key, options)
      if MissingTranslationData === exception
        if key.is_a?(String)
          return key
        elsif key.is_a?(Symbol)
          key.to_s =~ /.*\.([^.]+)/
          return $1.blank? ? key.to_s : $1.humanize
        else
          return key.to_s.humanize
        end
        #raise exception
      end
    end  
  end
end

class Object
  def _(*args)
    trans = "#{self.class}.#{args[0].to_s.underscore.gsub(' ', '_')}".to_sym
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

      # rid = resource_type.id
      def generate_position(rid)
        Property.maximum('position', :conditions => ['resource_type_id = ?', rid]) + 1
      end

      # update all empty columns for new properties of resource of a specific resource_type
      def update_resource_properties(rid)
        Resource.find_in_batches(:conditions => ['resource_type_id = ?', rid]) do |batch|
          batch.each do |resource|
            resource.get_empty_resource_properties.each{|rp| rp.save }
          end
        end
      end

    end
  end
end

class String
  def is_integer?
    self =~ /\A\d+\Z/
  end
end