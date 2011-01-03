class CreateCourses < ActiveRecord::Migration
  def self.up
    create_table :courses do |t|
    	t.column :location, :string
    	t.column :name, :string
    	t.column :warning, :string
    	t.column :start_date, :string
    	t.column :end_date, :string

      t.timestamps
    end
  end

  def self.down
    drop_table :courses
  end
end
