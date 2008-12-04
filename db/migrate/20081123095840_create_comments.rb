class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
    	t.column :title, :string
    	t.column :name, :string
    	t.column :email, :string
      t.column :body, :string
      t.column :node_id, :integer
      
      t.timestamps
    end
  end

  def self.down
    drop_table :comments
  end
end
