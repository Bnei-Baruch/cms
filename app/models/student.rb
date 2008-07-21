class Student < ActiveRecord::Base
	belongs_to :tree_node

	def self.list_all_students
		find(:all)
	end
	
end
