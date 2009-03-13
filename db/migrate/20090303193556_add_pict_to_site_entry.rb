class AddPictToSiteEntry < ActiveRecord::Migration
  def self.up
    migration_login

    resource_type = ResourceType.find(:first, :conditions => {:hrid => 'site_updates_entry'})
    raise 'Failed to find site_updates_entry resource type' unless resource_type
    
    picture_property = Property.new(:name => 'Picture',
      :field_type => 'File',
      :hrid => 'picture',
      :geometry => 'thumb:70x70!;',
      :resource_type_id => resource_type.id)
    raise 'Failed to create Picture property' unless picture_property
    picture_property.save!

  end

  def self.down
  end
end
