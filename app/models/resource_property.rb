class ResourceProperty < ActiveRecord::Base
	belongs_to :resource
	belongs_to :property
	
	def self.inheritance_column
		'property_type'
	end
end
