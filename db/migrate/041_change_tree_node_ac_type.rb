class ChangeTreeNodeAcType < ActiveRecord::Migration
  def self.up
    change_column :tree_node_ac_rights, :ac_type, :integer, :default => 1
  end

  def self.down
     change_column  :tree_node_ac_rights, :ac_type, :string, :length =>1, :null=>false, :default => 'r'
  end
end
