class AddListnameToStudent < ActiveRecord::Migration
  def self.up
    add_column :students, :listname, :string
  end

  def self.down
    remove_column :students, :listname
  end
end
