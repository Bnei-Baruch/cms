class ResourceProperty < ActiveRecord::Base
	belongs_to :resource
	belongs_to :property
	belongs_to :list_value

	def self.inheritance_column
		'property_type'
	end

	def value

	end

	def name
		resource.resource_type.resource_type_properties.find_by_property_id(property.id).name
	end
end
