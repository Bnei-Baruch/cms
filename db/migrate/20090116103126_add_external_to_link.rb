class AddExternalToLink < ActiveRecord::Migration
  def self.up
    migration_login

    resource_type = ResourceType.find(:first, :conditions => {:hrid => 'link'})
    raise 'Failed to find Link resource type' unless resource_type

    property = Property.new(
      :name => 'It is external link',
      :field_type => 'Boolean',
      :hrid => 'external',
      :resource_type_id => resource_type.id,
      :position => 5,
      :default_code => 'true',
      :is_required => false)
    raise 'Failed to create property \'external\'' unless property
    property.save!

    property = Property.new(
      :name => 'Icon',
      :field_type => 'File',
      :hrid => 'icon',
      :resource_type_id => resource_type.id,
      :position => 6,
      :is_required => false)
    raise 'Failed to create property \'icon\'' unless property
    property.save!
  end

  def self.down
    resource_type = ResourceType.find(:first, :conditions => {:hrid => 'link'})
    return unless resource_type

    property = Property.find(:first, :conditions => {:hrid => 'external', :resource_type_id => resource_type.id})
    property.delete
    property = Property.find(:first, :conditions => {:hrid => 'icon', :resource_type_id => resource_type.id})
    property.delete
  end
end
