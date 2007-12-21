class AddIndexesToPropertiesAndResourceTypes < ActiveRecord::Migration
  def self.up
		add_index :resource_types, :hrid
		add_index :properties, :hrid
  end

  def self.down
		remove_index :resource_types, :hrid
		remove_index :properties, :hrid
  end
end
