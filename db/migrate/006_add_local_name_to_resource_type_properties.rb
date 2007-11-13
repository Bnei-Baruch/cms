class AddLocalNameToResourceTypeProperties < ActiveRecord::Migration
  def self.up
		add_column :resource_type_properties, :local_name, :string
  end

  def self.down
		remove_column(:resource_type_properties, :local_name)
  end
end
