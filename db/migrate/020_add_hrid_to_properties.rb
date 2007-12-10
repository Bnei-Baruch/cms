class AddHridToProperties < ActiveRecord::Migration
  def self.up
		add_column :properties, :hrid, :string
  end

  def self.down
		remove_column(:properties, :hrid)
  end
end
