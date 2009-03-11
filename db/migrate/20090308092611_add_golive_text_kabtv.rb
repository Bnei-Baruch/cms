class AddGoliveTextKabtv < ActiveRecord::Migration
 def self.up
    migration_login

    resource_type = ResourceType.find(:first, :conditions => {:hrid => 'kabtv'})
    raise 'Failed to find kabtv resource type' unless resource_type

    property = Property.new(
      :name => 'Golive text',
      :field_type => 'String',
      :hrid => 'golive_text',
      :resource_type_id => resource_type.id,
      :is_required => false)
    raise 'Failed to create property \'Golive text\'' unless property
    property.save!

  end

  def self.down
    resource_type = ResourceType.find(:first, :conditions => {:hrid => 'kabtv'})
    return unless resource_type

    property = Property.find(:first, :conditions => {:hrid => 'golive_text', :resource_type_id => resource_type.id})
    property.delete

  end
end
