class AddGroupSystemColumn < ActiveRecord::Migration
  def self.up
    add_column :groups, :is_system_group, :boolean,:default=>false,:nil =>false
  end

  def self.down
    drop_column :groups, :is_system_group
  end
end
