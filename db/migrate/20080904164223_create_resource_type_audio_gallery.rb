class CreateResourceTypeAudioGallery < ActiveRecord::Migration
  def self.up

    migration_login

    create_audio
    create_audio_gallery
  end

  def self.create_audio
    resource_type = ResourceType.find(:first, :conditions => ['hrid = ?', 'audio'])
    if resource_type
      puts 'Audio resource type already exists'
      return
    end

    puts 'Going to create Audio'
      
    resource_type = ResourceType.new(:name => 'Audio',
      :name_code => '<title>',
      :hrid => 'audio')
    raise 'Failed to create Audio' unless resource_type
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
  end
  
  def self.create_audio_gallery
    resource_type = ResourceType.find(:first, :conditions => ['hrid = ?', 'audio_gallery'])
    if resource_type
      puts 'Audio Gallery resource type already exists'
      return
    end

    puts 'Going to create Audio Gallery'
      
    resource_type = ResourceType.new(:name => 'Audio Gallery',
      :name_code => '<title>',
      :hrid => 'audio_gallery')
    raise 'Failed to create Audio Gallery' unless resource_type
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
