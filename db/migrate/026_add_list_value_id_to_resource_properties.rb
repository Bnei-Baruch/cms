class AddListValueIdToResourceProperties < ActiveRecord::Migration
  def self.up
		add_column :resource_properties, :list_value_id, :integer
  end

  def self.down
		remove_column :resource_properties, :list_value_id
  end
end
