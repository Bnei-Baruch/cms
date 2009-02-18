class AddCacheMapTable < ActiveRecord::Migration
  def self.up
    create_table :cache_maps do |t|
      t.column :parent, :integer
      t.column :child, :integer
    end
  end

  def self.down
    drop_table :cache_maps
  end
end
