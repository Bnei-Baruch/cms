class AddSwitchToCampusRegistration < ActiveRecord::Migration
  def self.up
    migration_login

    resource_type = ResourceType.find(:first, :conditions => {:hrid => 'campus_form'})
    raise 'Failed to find Campus Form resource type' unless resource_type

    rid = resource_type.id

    property = Property.new(
      :name => 'Enable Payment',
      :field_type => 'Boolean',
      :hrid => 'enable_payment',
      :resource_type_id => rid,
      :position => generate_position(rid),
      :is_required => false)
    raise 'Failed to create property \'Enable Payment\'' unless property
    property.save!

  end

  def self.down
    migration_login

    resource_type = ResourceType.find(:first, :conditions => {:hrid => 'campus_form'})
    return unless resource_type

    property = Property.find(:first, :conditions => {:hrid => 'enable_payment', :resource_type_id => resource_type.id})
    if property
      resource_properties = ResourceProperty.find(:all, :conditions => {:property_id => property.id})
      resource_properties.each{ |rp| rp.delete }
      property.delete
    end
  end
end
