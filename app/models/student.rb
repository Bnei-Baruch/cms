class Student < ActiveRecord::Base
	belongs_to :tree_node

	def self.list_all_students
		find(:all, :order => "created_at DESC")
	end
	
end
