class CreateResourceAdminComment < ActiveRecord::Migration
  def self.up
     migration_login

    resource_type = ResourceType.find(:first, :conditions => ['hrid = ?', 'admin_comment'])
    if resource_type
      puts 'Amind Comment resource type already exists'
      return
    end

    puts 'Going to create Admin comment'
    
    resource_type = ResourceType.new(:name => 'Admin Comment',
      :name_code => '<name>',
      :hrid => 'admin_comment')
    raise 'Failed to create Admin comment' unless resource_type
    resource_type.save!
    
    #create properties
    
     name_property = Property.new(:name => 'Name',
      :field_type => 'String',
      :hrid => 'name',
      :resource_type_id => resource_type.id, 
      :position => 1,
      :is_required => true)
    raise 'Failed to create name_property' unless name_property
    name_property.save!
    
    
  end

  def self.down
  end
end
