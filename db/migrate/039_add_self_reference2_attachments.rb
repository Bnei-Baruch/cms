class AddSelfReference2Attachments < ActiveRecord::Migration
  def self.up
    add_column :attachments, :thumbnail_id, :integer
    add_index(:attachments, :thumbnail_id)
  end

  def self.down
    remove_column :attachments, :thumbnail_id
    drop_index(:attachments, :thumbnail_id)
  end
end
