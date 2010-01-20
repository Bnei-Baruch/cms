class AddPreferFlash < ActiveRecord::Migration
  def self.up
    migration_login

    resource_type = ResourceType.find(:first, :conditions => {:hrid => 'kabtv'})
    raise 'Failed to find kabtv resource type' unless resource_type

    property = Property.new(
    :name => 'Prefer Flash',
    :field_type => 'Boolean',
    :hrid => 'prefer_flash',
    :resource_type_id => resource_type.id,
    :position => 10,
    :is_required => false)
    raise 'Failed to create property \'Hide Title\'' unless property
    property.save!
  end

  def self.down
    migration_login
    
    resource_type = ResourceType.find(:first, :conditions => {:hrid => 'kabtv'})
    return unless resource_type

    property = Property.find(:first, :conditions => {:hrid => 'prefer_flash', :resource_type_id => resource_type.id})
    return unless property
    resource_properties = ResourceProperty.find(:all, :conditions => {:property_id => property.id})
    resource_properties.each{ |rp| rp.delete }
    property.delete
  end
end

