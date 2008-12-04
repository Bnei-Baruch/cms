class CommentAddField < ActiveRecord::Migration
  def self.up
      add_column :comments, :moderated, :boolean, :default => false, :null => false
  end

  def self.down
  end
end
