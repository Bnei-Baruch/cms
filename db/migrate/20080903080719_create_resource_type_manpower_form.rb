class CreateResourceTypeManpowerForm < ActiveRecord::Migration
  def self.up
     migration_login
    
    resource_type = ResourceType.find(:first, :conditions => ['hrid = ?', 'manpower_form'])
    if resource_type
      puts 'Manpower form already exists'
      return
    end

    puts 'Going to create Manpower form '
      
    resource_type = ResourceType.new(:name => 'Manpower form',
      :name_code => '<title>',
      :hrid => 'manpower_form')
    raise 'Failed to create Manpower form' unless resource_type
    resource_type.save!
      
    #create properties

    puts 'Going to create properties'
    
    title_property = Property.new(:name => 'Title',
      :field_type => 'String',
      :hrid => 'title',
      :resource_type_id => resource_type.id, 
      :position => 1,
      :is_required => true)
    raise 'Failed to create title_property' unless title_property
    title_property.save!

    email_property = Property.new(:name => 'Email',
      :field_type => 'String',
      :hrid => 'email',
      :resource_type_id => resource_type.id,
      :position => 2,
      :is_required => true)
    raise 'Failed to create Email property' unless email_property
    email_property.save!
  end

  def self.down
  end
end
