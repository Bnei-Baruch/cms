class CreateNumbers < ActiveRecord::Migration
  def self.up
    create_table :numbers do |t|
    end
  end

  def self.down
    drop_table :numbers
  end
end
