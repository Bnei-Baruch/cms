class AddFieldForComments < ActiveRecord::Migration
  def self.up
    add_column :comments, :is_spam, :boolean
    add_column :comments, :is_valid, :boolean
  end

  def self.down
  end
end
