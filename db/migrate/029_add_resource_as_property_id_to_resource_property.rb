class AddResourceAsPropertyIdToResourceProperty < ActiveRecord::Migration
  def self.up
		add_column :resource_properties, :resource_as_property_id, :integer
		add_column :resource_properties, :resource_property_id, :integer
  end

  def self.down
		remove_column :resource_properties, :resource_as_property_id
		remove_column :resource_properties, :resource_property_id
  end
end
