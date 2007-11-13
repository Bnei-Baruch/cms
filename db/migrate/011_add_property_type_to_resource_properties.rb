class AddPropertyTypeToResourceProperties < ActiveRecord::Migration
  def self.up
		add_column :resource_properties, :property_type, :string
  end

  def self.down
		remove_column(:resource_properties, :property_type)
  end
end
