class AddActsAsTree < ActiveRecord::Migration
  def self.up
    add_column :attachments, :parent_id, :integer
    add_column :attachments, :children_count, :integer
  end

  def self.down
    drop_column :attachments, :parent_id
    drop_column :attachments, :children_count
  end
end
