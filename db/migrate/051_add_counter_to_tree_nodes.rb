class AddCounterToTreeNodes < ActiveRecord::Migration
  def self.up
    add_column :tree_nodes, :tree_nodes_count, :integer, :default => 0
  end

  def self.down
    remove_column :tree_nodes, :tree_nodes_count
  end
end
