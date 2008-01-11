class AddToAttachment < ActiveRecord::Migration
  def self.up
    
    create_table :attachments do |t|
      t.column :filename, :string
      t.column :mime_type, :string
      t.column :size, :integer
      t.column :file, :binary
      t.column :md5, :string
      t.column :resource_property_id, :integer
      
      t.timestamps
    end

 		add_index :attachments, :resource_property_id

		add_column :resource_properties, :attachment_id, :integer
 		add_index :resource_properties, :attachment_id
  end

  def self.down
 		drop_index :attachments, :resource_property_id
 		drop_index :resource_properties, :attachment_id
		remove_column :resource_properties, :attachment_id
		drop_table :attachments
  end
end
