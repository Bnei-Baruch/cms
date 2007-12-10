class AddNameCodeToResourceType < ActiveRecord::Migration
  def self.up
		add_column :resource_types, :name_code, :string
  end

  def self.down
		remove_column(:resource_types, :name_code)
  end
end
