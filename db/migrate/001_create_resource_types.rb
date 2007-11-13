class CreateResourceTypes < ActiveRecord::Migration
  def self.up
    create_table :resource_types do |t|
      t.column :name, :string
      t.column :created_at, :timestamp
      t.column :updated_at, :timestamp
    end
  end

  def self.down
    drop_table :resource_types
  end
end
