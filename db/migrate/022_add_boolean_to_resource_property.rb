class AddBooleanToResourceProperty < ActiveRecord::Migration
  def self.up
		add_column :resource_properties, :boolean_value, :boolean
  end

  def self.down
		remove_column(:resource_properties, :boolean_value)
  end
end
