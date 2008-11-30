class CreateResourceTypeKabtv < ActiveRecord::Migration
  def self.up

    migration_login

    resource_type = ResourceType.find(:first, :conditions => ['hrid = ?', 'kabtv'])
    if resource_type
      puts 'Kabtv resource type already exists'
      return
    end

    puts 'Going to create kab.tv'

    resource_type = ResourceType.new(:name => 'kab.tv',
      :name_code => '<title>+" ("+<language>+")"',
      :hrid => 'kabtv')
    raise 'Failed to create kab.tv' unless resource_type
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

    language_property = Property.new(:name => 'Language',
      :field_type => 'String',
      :hrid => 'language',
      :resource_type_id => resource_type.id,
      :position => 2,
      :is_required => false)
    raise 'Failed to create language_property' unless language_property
    language_property.save!

    background_property = Property.new(:name => 'Background',
      :field_type => 'File',
      :hrid => 'background',
      :resource_type_id => resource_type.id,
      :position => 3,
      :is_required => false)
    raise 'Failed to create background_property' unless background_property
    background_property.save!

    bgcolor_property = Property.new(:name => 'Background Color',
      :field_type => 'String',
      :hrid => 'bgcolor',
      :resource_type_id => resource_type.id,
      :position => 4,
      :default_code => '#dae6fc',
      :is_required => false)
    raise 'Failed to create bgcolor_property' unless bgcolor_property
    bgcolor_property.save!
  end

  def self.down
  end
end
