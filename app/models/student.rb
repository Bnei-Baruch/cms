class Student < ActiveRecord::Base
	belongs_to :tree_node

	def self.list_all_students
		find(:all, :order => "created_at DESC")
	end
	
  def self.list_all_students_for_list(list_name)
		find(:all, :order => "created_at DESC", :conditions => { :listname => list_name })
	end
	
  
end
