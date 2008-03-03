class AddGeometryToProperties < ActiveRecord::Migration
  def self.up
    add_column :properties, :geometry, :string
  end

  def self.down
    remove_column :properties, :geometry
  end
end
