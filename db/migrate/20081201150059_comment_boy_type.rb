class CommentBoyType < ActiveRecord::Migration
  def self.up
    change_column :comments, :body, :text
  end

  def self.down
  end
end
