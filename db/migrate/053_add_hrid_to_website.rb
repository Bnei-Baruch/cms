class AddHridToWebsite < ActiveRecord::Migration
  def self.up
    add_column :websites, :hrid, :string
  end

  def self.down
    remove_column :websites, :hrid
  end
end
