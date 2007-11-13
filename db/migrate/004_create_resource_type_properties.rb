class CreateResourceTypeProperties < ActiveRecord::Migration
  def self.up
    create_table :resource_type_properties do |t|
      t.column :resource_id, :integer
      t.column :property_id, :integer
      t.column :position, :integer
    end
		add_index(:resource_type_properties, :resource_id)
		add_index(:resource_type_properties, :property_id)
  end

  def self.down
    drop_table :resource_type_properties
  end
end
