class CommentTreeNodIdNodeIdUnification < ActiveRecord::Migration
  def self.up
    remove_column :comments, :tree_node_id
    rename_column :comments, :node_id, :tree_node_id
  end

  def self.down
  end
end
