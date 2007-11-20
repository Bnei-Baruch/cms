class Association < ActiveRecord::Base
	belongs_to :parent, :class_name => 'ResourceType', :foreign_key => :parent_id
	belongs_to :child, :class_name => 'ResourceType', :foreign_key => :resource_type_id
	
	attr_accessor :should_destroy

	def self.association_types_select
		%W{linked embedded}.collect{|obj| [obj.camelize, obj]}	
	end
	def should_destroy?
		should_destroy.to_i == 1
	end

end
