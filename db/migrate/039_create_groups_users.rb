class CreateGroupsUsers < ActiveRecord::Migration
  def self.up
    create_table :groups_users, :id=>false  do |t|
      t.integer :group_id, :null => false
      t.integer :user_id, :null => false

      t.timestamps
    end

    add_index :groups_users, [:group_id, :user_id], :unique => true, :name => 'PK_groups_users'
    add_index :groups_users, :user_id, :name => 'IX_groups_users_user_id'

    execute "alter table groups_users  
    add constraint fk_groups_users_users
    foreign key  (user_id) references users(id)"

    execute "alter table groups_users  
    add constraint fk_groups_users_groups
    foreign key  (group_id) references groups(id)"
  end

  def self.down
    drop_table :groups_users
  end
end
