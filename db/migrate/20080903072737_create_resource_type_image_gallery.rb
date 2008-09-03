class CreateResourceTypeImageGallery < ActiveRecord::Migration
  def self.up
    
     migration_login
    
    resource_type = ResourceType.find(:first, :conditions => ['hrid = ?', 'picture_gallery'])
    if resource_type
      puts 'Picture Gallery already exists'
      return
    end

    puts 'Going to create Picture Gallery'
      
    resource_type = ResourceType.new(:name => 'Picture Gallery',
      :name_code => '<title>',
      :hrid => 'picture_gallery')
    raise 'Failed to create Picture Gallery' unless resource_type
    resource_type.save!
      
    #create properties

    puts 'Going to create properties'
    
    title_property = Property.new(:name => 'Title',
      :field_type => 'String',
      :hrid => 'title',
      :resource_type_id => resource_type.id, 
      :position => 1,
      :is_required => false)
    raise 'Failed to create title_property' unless title_property
    title_property.save!
  end

  def self.down
  end
end
