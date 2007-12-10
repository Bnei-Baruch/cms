class RemoveNameFromResources < ActiveRecord::Migration
  def self.up
  	remove_column :resources, :name
  end

  def self.down
  end
end
