# {:status => '404'} - removed from the system in perpose                                   
# nil - not found in our table or not active
# {:status => '301', :target => 'http://www.kab.co.il'} - redirected
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

