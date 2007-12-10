class CreateLists < ActiveRecord::Migration
  def self.up
    create_table :lists do |t|
      t.column :name, :string
      t.column :property_id, :integer
      t.column :resource_type_id, :integer
    end
  end

  def self.down
    drop_table :lists
  end
end
