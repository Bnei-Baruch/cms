class CreateResources < ActiveRecord::Migration
  def self.up
    create_table :resources do |t|
      t.column :name, :string
      t.column :resource_type_id, :integer
    end
  end

  def self.down
    drop_table :resources
  end
end
