class AddImageToPopupButton < ActiveRecord::Migration
  def self.up
    migration_login

    resource_type = ResourceType.find(:first, :conditions => {:hrid => 'popup'})
    raise 'Failed to find Popup resource type' unless resource_type

    rid = resource_type.id

    picture_property = Property.new(:name => 'Picture (165 x 40)',
                                    :field_type => 'File',
                                    :hrid => 'picture',
                                    :geometry => '165x40',
                                    :position => 1,
                                    :resource_type_id => resource_type.id)
    raise 'Failed to create Picture property' unless picture_property
    picture_property.save!
  end

  def self.down
    migration_login

    resource_type = ResourceType.find(:first, :conditions => {:hrid => 'popup'})
    return unless resource_type

    property = Property.find(:first, :conditions => {:hrid => 'picture', :resource_type_id => resource_type.id})
    if property
      resource_properties = ResourceProperty.find(:all, :conditions => {:property_id => property.id})
      resource_properties.each { |rp| rp.delete }
      property.delete
    end
  end
end
