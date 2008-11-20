class UpdateCampusForm6 < ActiveRecord::Migration
  def self.up
    migration_login
    
    resource_type = ResourceType.find(:first, :conditions => ['hrid = ?', 'campus_form'])
    unless resource_type
      puts 'Campus form not found, sorry!'
      return
    end
    
    puts 'Going to update Campus form'
    
    track_property = Property.new(:name => 'Tracker',
      :field_type => 'String',
      :hrid => 'track_string',
      :resource_type_id => resource_type.id, 
      :position => 22,
      :is_required => false)
    raise 'Failed to track_property' unless track_property
    track_property.save!
    
  end

  def self.down
  end
end
