class RemoveResourceTypeProperties < ActiveRecord::Migration
  def self.up
    drop_table :resource_type_properties
  end

  def self.down
  end
end
