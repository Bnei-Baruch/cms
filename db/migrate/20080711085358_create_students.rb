class CreateStudents < ActiveRecord::Migration
  def self.up
    create_table :students do |t|
    	t.column :name, :string
    	t.column :telephone, :string
    	t.column :email, :string    	

      t.timestamps
    end
  end

  def self.down
    drop_table :students
  end
end
