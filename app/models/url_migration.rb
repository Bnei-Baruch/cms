require 'csv'

# {:status => '404'} - removed from the system in perpose                                   
# nil - not found in our table or not active
# {:status => '301', :target => 'http://www.kab.co.il'} - redirected

class UrlMigration < ActiveRecord::Base
  
  def self.get_action_and_target(source)
	migration = find :first, :conditions => [ "source = ? AND upper(state) = ?", source, "ACTIVE" ]
	if (migration)
		if (migration.action == $config_manager.appl_settings[:url_migration_action][:action_404])
			return migration.action
		else	
			return [migration.action, migration.target]
		end
	else
		return nil
	end
  end

  
  def self.update_from_file(buf, delete_existing_migrations)

	if (delete_existing_migrations)
  	  url_migrations = find(:all)
	  url_migrations.each do |url_migration|
	    url_migration.update_attributes(:state => "Deleted")
	  end
	end      

	CSV::Reader.parse(buf) do |row|
      if (row[0] != "Source")
	    url_migration = find_by_source(row[0])
	    if (url_migration)
	      url_migration.update_attributes(:target => row[1], :action => row[2], :state  => row[3])
	    else
		  url_migration = new(:source => row[0], :target => row[1], :action => row[2],:state  => row[3])		
	    end
	    err = url_migration.save
      end
	  break if !row[0]
	end
    
	return true
  end

end

