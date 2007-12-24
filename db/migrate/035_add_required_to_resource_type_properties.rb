class AddRequiredToResourceTypeProperties < ActiveRecord::Migration
  def self.up
		add_column :resource_type_properties, :is_required, :boolean
  end

  def self.down
		remove_column :resource_type_properties, :is_required
  end
end
