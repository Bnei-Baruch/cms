class AddPlaceholderToTreeNodes < ActiveRecord::Migration
  def self.up
    add_column :tree_nodes, :placeholder, :string
  end

  def self.down
    remove_column :tree_nodes, :placeholder
  end
end
