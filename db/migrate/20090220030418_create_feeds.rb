class CreateFeeds < ActiveRecord::Migration
  def self.up
    create_table :feeds do |t|
      t.column :section_id, :integer
      t.column :feed_type, :string
      t.column :data, :text
      t.timestamps
    end
  end

  def self.down
    drop_table :feeds
  end
end
