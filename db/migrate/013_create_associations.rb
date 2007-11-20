class CreateAssociations < ActiveRecord::Migration
  def self.up
    create_table :associations do |t|
      t.column :parent_id, :integer
      t.column :resource_id, :integer
      t.column :position, :integer
      t.column :type, :string
    end
  end

  def self.down
    drop_table :associations
  end
end
