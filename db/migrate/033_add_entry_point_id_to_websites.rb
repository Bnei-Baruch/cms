class AddEntryPointIdToWebsites < ActiveRecord::Migration
  def self.up
		add_column :websites, :entry_point_id, :integer
  end

  def self.down
		remove_column :websites, :entry_point_id
  end
end
