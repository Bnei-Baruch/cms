class CreateLabelTypes < ActiveRecord::Migration
  def self.up
    create_table :label_types do |t|
    end
  end

  def self.down
    drop_table :label_types
  end
end
