class CreateUrlMigrations < ActiveRecord::Migration
  def self.up
    create_table :url_migrations do |t|
      t.string :source
      t.string :target
      t.string :action
      t.string :state

      t.timestamps
    end
  end

  def self.down
    drop_table :url_migrations
  end
end
