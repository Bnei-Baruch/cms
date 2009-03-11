class AddGoliveLinkKabtv < ActiveRecord::Migration
   def self.up
    migration_login

    resource_type = ResourceType.find(:first, :conditions => {:hrid => 'kabtv'})
    raise 'Failed to find kabtv resource type' unless resource_type

    property = Property.new(
      :name => 'Golive link',
      :field_type => 'String',
      :hrid => 'golive_link',
      :resource_type_id => resource_type.id,
      :is_required => false)
    raise 'Failed to create property \'Golive link\'' unless property
    property.save!

  end

  def self.down
    resource_type = ResourceType.find(:first, :conditions => {:hrid => 'kabtv'})
    return unless resource_type

    property = Property.find(:first, :conditions => {:hrid => 'golive_link', :resource_type_id => resource_type.id})
    property.delete

  end
end