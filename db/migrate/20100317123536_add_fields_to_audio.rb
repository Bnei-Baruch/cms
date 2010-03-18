class AddFieldsToAudio < ActiveRecord::Migration
  def self.up
    migration_login

    resource_type = ResourceType.find(:first, :conditions => {:hrid => 'audio'})
    raise 'Failed to find audio resource type' unless resource_type

    rid = resource_type.id

    property = Property.new(
    :name => 'Artist',
    :field_type => 'String',
    :hrid => 'artist',
    :resource_type_id => rid,
    :position => generate_position(rid),
    :is_required => false)
    raise 'Failed to create property \'Artist\'' unless property
    property.save!

    property = Property.new(
    :name => 'Lyrics',
    :field_type => 'Text',
    :hrid => 'lyrics',
    :resource_type_id => rid,
    :position => generate_position(rid),
    :is_required => false)
    raise 'Failed to create property \'Lyrics\'' unless property
    property.save!

    property = Property.new(
    :name => 'Download is permitted',
    :field_type => 'Boolean',
    :hrid => 'enable_download',
    :resource_type_id => rid,
    :position => generate_position(rid),
    :is_required => false)
    raise 'Failed to create property \'Download is permitted\'' unless property
    property.save!

    update_resource_properties(rid)
  end

  def self.down
    migration_login

    resource_type = ResourceType.find(:first, :conditions => {:hrid => 'audio'})
    return unless resource_type

    property = Property.find(:first, :conditions => {:hrid => 'artist', :resource_type_id => resource_type.id})
    if property
      resource_properties = ResourceProperty.find(:all, :conditions => {:property_id => property.id})
      resource_properties.each{ |rp| rp.delete }
      property.delete
    end
    property = Property.find(:first, :conditions => {:hrid => 'lyrics', :resource_type_id => resource_type.id})
    if property
      resource_properties = ResourceProperty.find(:all, :conditions => {:property_id => property.id})
      resource_properties.each{ |rp| rp.delete }
      property.delete
    end
    property = Property.find(:first, :conditions => {:hrid => 'enable_download', :resource_type_id => resource_type.id})
    if property
      resource_properties = ResourceProperty.find(:all, :conditions => {:property_id => property.id})
      resource_properties.each{ |rp| rp.delete }
      property.delete
    end
  end
end
