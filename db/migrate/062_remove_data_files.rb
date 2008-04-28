class RemoveDataFiles < ActiveRecord::Migration
  def self.up
	drop_table :data_files
  end

  def self.down
  end
end
