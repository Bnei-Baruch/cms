class CreateResourceProperties < ActiveRecord::Migration
  def self.up
    create_table :resource_properties do |t|
      t.column :resource_id, :integer
      t.column :property_id, :integer
      t.column :position, :integer
      t.column :vc_value, :string
      t.column :numb_value, :integer
      t.column :clob_value, :text
      t.column :date_value, :date
    end
		add_index(:resource_properties, :resource_id)
		add_index(:resource_properties, :property_id)
  end

  def self.down
    drop_table :resource_properties
  end
end
