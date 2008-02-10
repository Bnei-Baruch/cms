class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :username , :null => false
      t.string :password , :null => false
      t.string :banned_reson
      t.string :salt, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
