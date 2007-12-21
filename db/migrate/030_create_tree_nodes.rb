class CreateTreeNodes < ActiveRecord::Migration
  def self.up
    create_table :tree_nodes do |t|
      t.integer :parent_id
      t.integer :resource_id
      t.integer :position
      t.string :node_type
      t.string :permalink

      t.timestamps
    end
  end

  def self.down
    drop_table :tree_nodes
  end
end
