class CommentsAddTreeNodeIdCol < ActiveRecord::Migration
  def self.up
     add_column :comments, :tree_node_id, :integer
  end

  def self.down
  end
end
