class HideBitratesOnSpecialBroadcast < ActiveRecord::Migration
  def self.up
    migration_login

    resource_type = ResourceType.find(:first, :conditions => {:hrid => 'kabtv'})
    raise 'Failed to find kabtv resource type' unless resource_type

    rid = resource_type.id
    property = Property.new(
    :name => 'Hide Bitrates',
    :field_type => 'Boolean',
    :hrid => 'hide_bitrates',
    :resource_type_id => rid,
    :position => generate_position(rid),
    :is_required => false)
    raise 'Failed to create property \'Hide Bitrates\'' unless property
    property.save!

    update_resource_properties(rid)
  end

  def self.down
    migration_login

    resource_type = ResourceType.find(:first, :conditions => {:hrid => 'kabtv'})
    return unless resource_type

    property = Property.find(:first, :conditions => {:hrid => 'hide_bitrates', :resource_type_id => resource_type.id})
    if property
      resource_properties = ResourceProperty.find(:all, :conditions => {:property_id => property.id})
      resource_properties.each{ |rp| rp.delete }
      property.delete
    end
  end
end
