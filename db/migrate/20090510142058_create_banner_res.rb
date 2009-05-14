class CreateBannerRes < ActiveRecord::Migration
  def self.up
    migration_login

    resource_type = ResourceType.find(:first, :conditions => ['hrid = ?', 'banner'])
    if resource_type
      puts 'Banner exists'
      return
    end

    puts 'Going to create Banner '

    resource_type = ResourceType.new(:name => 'Banner',
      :name_code => '<banner>',
      :hrid => 'banner')
    raise 'Failed to create Banner' unless resource_type
    resource_type.save!

    puts 'Bannercreation OK'

    #create properties

    puts 'Going to create properties'

    name_property = Property.new(:name => 'Name',
      :field_type => 'String',
      :hrid => 'name',
      :resource_type_id => resource_type.id,
      :position => 1,
      :is_required => false)
    raise 'Failed to create name_property' unless name_property
    name_property.save!

    picture_property = Property.new(:name => 'Picture',
      :field_type => 'File',
      :hrid => 'picture',
      :geometry => 'thumb:240x110!;',
      :position => 1,
      :resource_type_id => resource_type.id)
    raise 'Failed to create Picture property' unless picture_property
    picture_property.save!

    description_property = Property.new(:name => 'Description',
      :field_type => 'Text',
      :hrid => 'description',
      :resource_type_id => resource_type.id,
      :position => 3,
      :is_required => false)
    raise 'Failed to create description_property' unless description_property
    description_property.save!

    link_property  = Property.new(:name => 'Link',
      :field_type => 'String',
      :hrid => 'link',
      :resource_type_id => resource_type.id,
      :position => 4,
      :is_required => false)
    raise 'Failed to create link_property' unless link_property
    link_property.save!

    puts 'Properties creation OK'
    
  end

  def self.down
  end
end
