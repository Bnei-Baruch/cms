class CreateWebsites < ActiveRecord::Migration
  def self.up
    create_table :websites do |t|
      t.column :name, :string
      t.column :domain, :string
      t.column :prefix, :string
    end
  end

  def self.down
    drop_table :websites
  end
end
