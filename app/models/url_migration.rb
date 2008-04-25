class UrlMigration < ActiveRecord::Base

  def self.get_action_and_target(source)
	migration = find :first, :conditions => [ "source = ?", source ]
	if (migration)	
		return [migration.action, migration.target]
	else
		return ["Not Found", ""]
	end
  end

end
