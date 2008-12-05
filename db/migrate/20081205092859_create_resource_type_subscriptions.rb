class CreateResourceTypeSubscriptions < ActiveRecord::Migration
  def self.up
    
    migration_login
    
    resource_type = ResourceType.find(:first, :conditions => ['hrid = ?', 'subscription'])
    if resource_type
      puts 'Subscription exists'
      return
    end

    puts 'Going to create Subscription'
      
    resource_type = ResourceType.new(:name => 'Subscription',
                                      :name_code => '<subscription>',
                                      :hrid => 'subscription')
    raise 'Failed to create Subscription' unless resource_type
    resource_type.save!
     
    puts 'Subscription creation OK'
     
    #create properties

    puts 'Going to create properties'
    
    description_property = Property.new(:name => 'Description',
      :field_type => 'Text',
      :hrid => 'description',
      :resource_type_id => resource_type.id, 
      :position => 1,
      :is_required => false)
    raise 'Failed to create description_property' unless description_property
    description_property.save!
    
    puts 'Properties creation OK'
  end

  def self.down
  end
end
