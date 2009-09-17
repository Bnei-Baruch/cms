class AddHideDownloadColumnToMediaCasting < ActiveRecord::Migration
  def self.up
    migration_login

    resource_type = ResourceType.find(:first, :conditions => {:hrid => 'media_casting'})
    raise 'Failed to find kabtv resource type' unless resource_type

    property = Property.new(
      :name => 'Hide Download Link',
      :field_type => 'Boolean',
      :hrid => 'hide_download_link',
      :resource_type_id => resource_type.id,
      :is_required => false)
    raise 'Failed to create property \'Hide Download Link\'' unless property
    property.save!

  end

  def self.down
    migration_login
    
    resource_type = ResourceType.find(:first, :conditions => {:hrid => 'media_casting'})
    return unless resource_type

    property = Property.find(:first, :conditions => {:hrid => 'hide_download_link', :resource_type_id => resource_type.id})
    return unless property
    resource_properties = ResourceProperty.find(:all, :conditions => {:property_id => property.id})
    resource_properties.each{ |rp| rp.delete }
    property.delete
  end
end
