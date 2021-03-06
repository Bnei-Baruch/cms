class AddEventToBanner < ActiveRecord::Migration
  def self.up
    migration_login

    resource_type = ResourceType.find(:first, :conditions => { :hrid => 'banner' })
    raise 'Failed to find banner resource type' unless resource_type

    rid      = resource_type.id
    property = Property.new(
        :name             => 'Event name',
        :field_type       => 'String',
        :hrid             => 'event_name',
        :resource_type_id => rid,
        :position         => generate_position(rid),
        :is_required      => true)
    raise 'Failed to create property \'Event name\'' unless property
    property.save!

    update_resource_properties(rid)
  end

  def self.down
    migration_login

    resource_type = ResourceType.find(:first, :conditions => { :hrid => 'banner' })
    return unless resource_type

    property = Property.find(:first, :conditions => { :hrid => 'event_name', :resource_type_id => resource_type.id })
    if property
      resource_properties = ResourceProperty.find(:all, :conditions => { :property_id => property.id })
      resource_properties.each { |rp| rp.delete }
      property.delete
    end
  end
end
