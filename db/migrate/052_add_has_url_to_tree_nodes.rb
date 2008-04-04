class AddHasUrlToTreeNodes < ActiveRecord::Migration
  def self.up
    add_column :tree_nodes, :has_url, :boolean, :default => false
  end

  def self.down
    remove_column :tree_nodes, :has_url
  end
end
