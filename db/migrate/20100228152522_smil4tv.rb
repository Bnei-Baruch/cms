class Smil4tv < ActiveRecord::Migration
  def self.up
    migration_login

    resource_type = ResourceType.find(:first, :conditions => {:hrid => 'kabtv'})
    raise 'Failed to find kabtv resource type' unless resource_type

    rid = resource_type.id
    property = Property.new(
    :name => 'SMIL URL',
    :field_type => 'String',
    :hrid => 'smil_url',
    :resource_type_id => rid,
    :position => generate_position(rid),
    :is_required => false)
    raise 'Failed to create property \'SMIL URL\'' unless property
    property.save!

    property = Property.new(
    :name => 'ID of Analyzer',
    :field_type => 'String',
    :hrid => 'analyzer_id',
    :resource_type_id => rid,
    :position => generate_position(rid),
    :is_required => false)
    raise 'Failed to create property \'Analyzer ID\'' unless property
    property.save!

    update_resource_properties(rid)
  end

  def self.down
    migration_login

    resource_type = ResourceType.find(:first, :conditions => {:hrid => 'kabtv'})
    return unless resource_type

    property = Property.find(:first, :conditions => {:hrid => 'smil_url', :resource_type_id => resource_type.id})
    if property
      resource_properties = ResourceProperty.find(:all, :conditions => {:property_id => property.id})
      resource_properties.each{ |rp| rp.delete }
      property.delete
    end
    property = Property.find(:first, :conditions => {:hrid => 'analyzer_id', :resource_type_id => resource_type.id})
    if property
      resource_properties = ResourceProperty.find(:all, :conditions => {:property_id => property.id})
      resource_properties.each{ |rp| rp.delete }
      property.delete
    end
  end
end
