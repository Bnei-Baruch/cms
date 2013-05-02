class CreateBlocks < ActiveRecord::Migration
  def self.up
    create_table :blocks do |t|
      t.column :name, :string
      t.column :content, :text

      t.timestamps
    end
  end

  def self.down
    drop_table :blocks
  end
end
