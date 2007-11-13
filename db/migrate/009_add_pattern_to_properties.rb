class AddPatternToProperties < ActiveRecord::Migration
  def self.up
		add_column :properties, :pattern, :string
  end

  def self.down
		remove_column :properties, :pattern
  end
end
