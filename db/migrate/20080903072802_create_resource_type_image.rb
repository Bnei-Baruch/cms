class CreateResourceTypeImage < ActiveRecord::Migration
  def self.up
    migration_login
    
    resource_type = ResourceType.find(:first, :conditions => ['hrid = ?', 'image'])
    if resource_type
      puts 'Image already exists'
      return
    end

    puts 'Going to create Image'
      
    resource_type = ResourceType.new(:name => 'Image',
      :name_code => '<title>',
      :hrid => 'image')
    raise 'Failed to create Image' unless resource_type
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

    picture_property = Property.new(:name => 'Picture',
      :field_type => 'File',
      :hrid => 'picture',
      :geometry => 'thumb:90x90!;',
      :resource_type_id => resource_type.id,
      :position => 2,
      :is_required => true)
    raise 'Failed to create Picture property' unless picture_property
    picture_property.save!
  end

  def self.down
  end
end
