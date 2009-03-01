class HideOnNavigationIsTrue < ActiveRecord::Migration
  def self.up
    migration_login

    property = Property.find(:first, :conditions => {:hrid => 'hide_on_navigation'})
    raise 'Failed to find Link resource type' unless property
    Property.update(property.id, {:default_code => "true"})
    
    
  end

  def self.down
    migration_login

    property = Property.find(:first, :conditions => {:hrid => 'hide_on_navigation'})
    raise 'Failed to find Link resource type' unless property
    Property.update(property.id, {:default_code => ""})
  end
end
