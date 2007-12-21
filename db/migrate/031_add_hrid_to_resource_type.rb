class AddHridToResourceType < ActiveRecord::Migration
  def self.up
		add_column :resource_types, :hrid, :string
  end

  def self.down
		remove_column :resource_types, :hrid
  end
end
