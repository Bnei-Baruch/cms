class AddDefaultUserWebsiteColumn < ActiveRecord::Migration
  def self.up
    add_column :users, :website_id, :int
    add_column :users, :email, :string
  end

  def self.down
    remove_column :users, :email
    remove_column :users, :website_id
  end
end
