class CommentModifField < ActiveRecord::Migration
  def self.up
      remove_column :comments, :moderated
      change_column :comments, :is_valid, :integer, :default => '0'
  end

  def self.down
  end
end
