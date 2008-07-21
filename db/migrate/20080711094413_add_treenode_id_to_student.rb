class AddTreenodeIdToStudent < ActiveRecord::Migration
  def self.up
  	add_column :students, :tree_node_id, :integer
  end

  def self.down
  	remove_column :students, :tree_node_id
  end
end
