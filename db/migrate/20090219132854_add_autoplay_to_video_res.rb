class AddAutoplayToVideoRes < ActiveRecord::Migration
   def self.up
    migration_login

    resource_type = ResourceType.find(:first, :conditions => {:hrid => 'video'})
    raise 'Failed to find video resource type' unless resource_type

    property = Property.new(
      :name => 'Autoplay',
      :field_type => 'Boolean',
      :hrid => 'autoplay',
      :resource_type_id => resource_type.id,
      :is_required => false)
    raise 'Failed to create property \'Autoplay\'' unless property
    property.save!

  end

  def self.down
    resource_type = ResourceType.find(:first, :conditions => {:hrid => 'video'})
    return unless resource_type

    property = Property.find(:first, :conditions => {:hrid => 'autoplay', :resource_type_id => resource_type.id})
    property.delete

  end
end