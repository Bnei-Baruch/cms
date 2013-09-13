class AddPreferBbplayer < ActiveRecord::Migration
  def self.up
    migration_login

    resource_type = ResourceType.find(:first, :conditions => {:hrid => 'kabtv'})
    raise 'Failed to find kabtv resource type' unless resource_type

    property = Property.new(
        :name => 'Prefer BBPlayer',
        :field_type => 'Boolean',
        :hrid => 'prefer_bbplayer',
        :resource_type_id => resource_type.id,
        :position => generate_position(resource_type.id),
        :is_required => false)
    raise 'Failed to create property \'Prefer BBPlayer\'' unless property
    property.save!

    property = Property.new(
        :name => 'BBPlayer',
        :field_type => 'Plaintext',
        :hrid => 'bbplayer',
        :resource_type_id => resource_type.id,
        :position => generate_position(resource_type.id),
        :is_required => false)
    raise 'Failed to create property \'BBPlayer\'' unless property
    property.save!
  end

  def self.down
    migration_login

    resource_type = ResourceType.find(:first, :conditions => {:hrid => 'kabtv'})
    return unless resource_type

    property = Property.find(:first, :conditions => {:hrid => 'prefer_bbplayer', :resource_type_id => resource_type.id})
    return unless property
    resource_properties = ResourceProperty.find(:all, :conditions => {:property_id => property.id})
    resource_properties.each{ |rp| rp.delete }
    property.delete

    property = Property.find(:first, :conditions => {:hrid => 'bbplayer', :resource_type_id => resource_type.id})
    return unless property
    resource_properties = ResourceProperty.find(:all, :conditions => {:property_id => property.id})
    resource_properties.each{ |rp| rp.delete }
    property.delete
  end
end
