class AddUrlToKabtv < ActiveRecord::Migration
  def self.up

    migration_login

    resource_type = ResourceType.find(:first, :conditions => ['hrid = ?', 'kabtv'])
    if not resource_type
      puts 'Kabtv resource type doesn\'t exists'
      return
    end

    puts 'Going to create kab.tv Target field'

    target_property = Property.new(:name => 'Target',
      :field_type => 'String',
      :hrid => 'target',
      :resource_type_id => resource_type.id,
      :position => 1,
      :is_required => false)
    raise 'Failed to create target_property' unless target_property
    target_property.save!
  end

  def self.down
  end
end
