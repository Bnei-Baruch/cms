class RenameTypeInProperties < ActiveRecord::Migration
  def self.up
		rename_column :properties, :type, :field_type
  end

  def self.down
		rename_column :properties, :field_type, :type
	end
end
