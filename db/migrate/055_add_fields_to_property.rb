class AddFieldsToProperty < ActiveRecord::Migration
  def self.up
    add_column :properties, :resource_type_id, :integer
    add_column :properties, :position, :integer
    add_column :properties, :is_required, :boolean
  end

  def self.down
    remove_column :properties, :resource_type_id
    remove_column :properties, :position
    remove_column :properties, :is_required
  end
end
