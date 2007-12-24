class AddPatternTextToProperty < ActiveRecord::Migration
  def self.up
		add_column :properties, :pattern_text, :string
  end

  def self.down
		remove_column :properties, :pattern_text
  end
end
