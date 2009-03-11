class AddGolivenowTotv < ActiveRecord::Migration
  def self.up
    migration_login

    resource_type = ResourceType.find(:first, :conditions => {:hrid => 'kabtv'})
    raise 'Failed to find video resource type' unless resource_type

    property = Property.new(
      :name => 'Golive',
      :field_type => 'Boolean',
      :hrid => 'golive',
      :resource_type_id => resource_type.id,
      :is_required => false)
    raise 'Failed to create property \'Golive\'' unless property
    property.save!

  end

  def self.down
    resource_type = ResourceType.find(:first, :conditions => {:hrid => 'kabtv'})
    return unless resource_type

    property = Property.find(:first, :conditions => {:hrid => 'golive', :resource_type_id => resource_type.id})
    property.delete

  end
end
