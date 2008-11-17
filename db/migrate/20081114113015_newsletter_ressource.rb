class NewsletterRessource < ActiveRecord::Migration
  def self.up
    migration_login
    
    resource_type = ResourceType.find(:first, :conditions => ['hrid = ?', 'newsletter'])
    if resource_type
      puts 'Newsletter already exists'
      return
    end

    puts 'Going to create Newsletter '
      
    resource_type = ResourceType.new(:name => 'Newsletter form',
      :name_code => '<title>',
      :hrid => 'newsletter')
    raise 'Failed to create Newsletter' unless resource_type
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

    name_property = Property.new(:name => 'Name',
      :field_type => 'String',
      :hrid => 'name',
      :resource_type_id => resource_type.id,
      :position => 2,
      :is_required => true)
    raise 'Failed to create name property' unless name_property
    name_property.save!
    
    id_property = Property.new(:name => 'ID',
      :field_type => 'String',
      :hrid => 'ID',
      :resource_type_id => resource_type.id,
      :position => 3,
      :is_required => true)
    raise 'Failed to create Id property' unless id_property
    id_property.save!
    
    text_button_property = Property.new(:name => 'Text Button',
      :field_type => 'String',
      :hrid => 'text_button',
      :resource_type_id => resource_type.id,
      :position => 4,
      :is_required => true)
    raise 'Failed to create Text button property' unless text_button_property
    text_button_property.save!
  end

  def self.down
  end
end
