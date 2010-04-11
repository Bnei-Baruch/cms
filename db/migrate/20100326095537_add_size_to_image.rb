class AddSizeToImage < ActiveRecord::Migration
  def self.up
    add_column :attachments, :width, :integer
    add_column :attachments, :height, :integer
  end

  def self.down
    remove_column :attachments, :width
    remove_column :attachments, :height
  end
end
