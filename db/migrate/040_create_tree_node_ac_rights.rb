class CreateTreeNodeAcRights < ActiveRecord::Migration
  def self.up
    create_table :tree_node_ac_rights do |t|
      t.integer :tree_node_id, :null=>false
      t.string :ac_type, :length =>1, :null=>false, :default => 'r'
      t.integer :group_id, :null=>false
      t.boolean :is_automatic, :default => false , :null =>false
 
      t.timestamps
    end
    
        add_index :tree_node_ac_rights, [:tree_node_id, :ac_type, :group_id], :unique => true, :name => 'PK_tree_node_ac_rights'
	add_index :tree_node_ac_rights, :group_id, :name => 'IX_:tree_node_ac_rights_group_id'
        add_index :tree_node_ac_rights, :tree_node_id, :name => 'IX_:tree_node_ac_rights_tree_node_id'
        
    	execute "alter table tree_node_ac_rights  
               add constraint fk_tree_node_ac_rights_groups
               foreign key  (group_id) references groups(id)"
    
       execute "alter table tree_node_ac_rights  
               add constraint fk_tree_node_ac_rights_tree_nodes
               foreign key  (tree_node_id) references tree_nodes(id)"
  end

  def self.down
    drop_table :tree_node_ac_rights
  end
end
