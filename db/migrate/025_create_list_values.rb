class CreateListValues < ActiveRecord::Migration
  def self.up
    create_table :list_values do |t|
      t.column :list_id, :integer
      t.column :string_value, :string
      t.column :number_value, :integer
      t.column :text_value, :text
      t.column :date_value, :date
    end
  end

  def self.down
    drop_table :list_values
  end
end
