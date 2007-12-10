class AddListIdToProperty < ActiveRecord::Migration
  def self.up
		add_column :properties, :list_id, :integer
  end

  def self.down
		remove_column :properties, :list_id
  end
end
