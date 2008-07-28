class AddAdwordsToStudent < ActiveRecord::Migration
  def self.up
  	add_column :students, :adwords, :string
  end

  def self.down
  	remove_column :students, :adwords
  end
end
