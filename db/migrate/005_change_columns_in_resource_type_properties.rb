class ChangeColumnsInResourceTypeProperties < ActiveRecord::Migration
  def self.up
		rename_column :resource_type_properties, :resource_id, :resource_type_id
  end

  def self.down
  end
end
