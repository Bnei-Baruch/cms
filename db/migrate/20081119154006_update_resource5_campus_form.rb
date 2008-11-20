class UpdateResource5CampusForm < ActiveRecord::Migration
  def self.up
     migration_login
    
    resource_type = ResourceType.find(:first, :conditions => ['hrid = ?', 'campus_form'])
    unless resource_type
      puts 'Campus form not found, sorry!'
      return
    end
    
    puts 'Going to update Campus form'
    
    centered_property = Property.new(:name => 'Centered',
      :field_type => 'Boolean',
      :hrid => 'centered',
      :resource_type_id => resource_type.id, 
      :position => 21,
      :is_required => false)
    raise 'Failed to centered_property' unless centered_property
    centered_property.save!
  end

  def self.down
  end
end
