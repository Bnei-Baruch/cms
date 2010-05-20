class AddFreeTextToIframe < ActiveRecord::Migration
  def self.up
    migration_login

    resource_type = ResourceType.find(:first, :conditions => {:hrid => 'iframe'})
    raise 'Failed to find iframe resource type' unless resource_type

    rid = resource_type.id

    property = Property.new(
    :name => 'Additional parameters',
    :field_type => 'Plaintext',
    :hrid => 'add_params',
    :resource_type_id => rid,
    :position => generate_position(rid),
    :is_required => false)
    raise 'Failed to create property \'Additional parameters\'' unless property
    property.save!

    update_resource_properties(rid)
  end

  def self.down
    migration_login

    resource_type = ResourceType.find(:first, :conditions => {:hrid => 'iframe'})
    return unless resource_type

    property = Property.find(:first, :conditions => {:hrid => 'add_params', :resource_type_id => resource_type.id})
    if property
      resource_properties = ResourceProperty.find(:all, :conditions => {:property_id => property.id})
      resource_properties.each{ |rp| rp.delete }
      property.delete
    end
  end
end
