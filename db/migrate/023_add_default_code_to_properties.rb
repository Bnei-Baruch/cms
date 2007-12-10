class AddDefaultCodeToProperties < ActiveRecord::Migration
  def self.up
		add_column :properties, :default_code, :string
  end

  def self.down
		remove_column :properties, :default_code
  end
end
