class AddMainToTreeNode < ActiveRecord::Migration
  def self.up
    add_column :tree_nodes, :is_main, :boolean
  end

  def self.down
    remove_column :tree_nodes, :is_main
  end
end
