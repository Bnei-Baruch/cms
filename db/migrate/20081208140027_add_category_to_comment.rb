class AddCategoryToComment < ActiveRecord::Migration
  def self.up
    add_column :comments, :category, :integer
  end

  def self.down
  end
end
