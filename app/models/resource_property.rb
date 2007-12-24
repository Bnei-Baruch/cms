class ResourceProperty < ActiveRecord::Base
	belongs_to :resource
	belongs_to :property
	belongs_to :list_value

	validate :match_pattern

	def self.inheritance_column
		'property_type'
	end

	def to_param
		self.id.to_s
  end

	def value(klass = 'number_value')
		v = @attributes[klass]
		if self.new_record? && 
				(v.nil? || v.empty?)
			eval default_code
		else
			v
		end
	end

	def name
		resource.resource_type.resource_type_properties.find_by_property_id(property.id).name
	end

	protected	
	
	def default_code
		code = self.property.default_code
		code.nil? ? "" : code
	end

	def match_pattern
		return if property.pattern.blank?
		
    unless value.to_s =~ Regexp.new(property.pattern, Regexp::IGNORECASE, 'u')
      errors.add(:value, "does not match pattern (#{property.pattern})")
    end
	end
end
