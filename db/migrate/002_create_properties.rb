class CreateProperties < ActiveRecord::Migration
  def self.up
    create_table :properties do |t|
      t.column :name, :string
      t.column :type, :string
    end
  end

  def self.down
    drop_table :properties
  end
end
