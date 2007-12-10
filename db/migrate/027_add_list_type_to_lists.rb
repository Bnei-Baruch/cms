class AddListTypeToLists < ActiveRecord::Migration
  def self.up
		add_column :lists, :list_type, :string
  end

  def self.down
		remove_column :lists, :list_type
  end
end
