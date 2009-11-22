class AddUpdatedAtToResource < ActiveRecord::Migration
  def self.up
    add_column :resources, :updated_at, :timestamp
    add_column :resources, :created_at, :timestamp
  end

  def self.down
    remove_column :resources, :updated_at
    remove_column :resources, :created_at
  end
end
