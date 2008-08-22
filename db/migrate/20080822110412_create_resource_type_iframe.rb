class CreateResourceTypeIframe < ActiveRecord::Migration
  def self.up
    
    migration_login
    
    resource_type = ResourceType.find(:first, :conditions => ['hrid = ?', 'iframe'])
    if resource_type
      puts 'Iframe exists'
      return
    end

    puts 'Going to create Iframe'
      
    resource_type = ResourceType.new(:name => 'Iframe',
      :name_code => '<title>',
      :hrid => 'iframe')
    raise 'Failed to create Iframe' unless resource_type
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

    url_property = Property.new(:name => 'Url',
      :field_type => 'String',
      :hrid => 'url',
      :resource_type_id => resource_type.id, 
      :position => 2,
      :is_required => false)
    raise 'Failed to create url_property' unless url_property
    url_property.save!

    height_property = Property.new(:name => 'Height',
      :field_type => 'Number',
      :hrid => 'height',
      :resource_type_id => resource_type.id, 
      :position => 3,
      :is_required => false)
    raise 'Failed to create height_property' unless height_property
    height_property.save!
  end

  def self.down
  end

end
