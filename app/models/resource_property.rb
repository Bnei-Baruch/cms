class ResourceProperty < ActiveRecord::Base
	belongs_to :resource
	belongs_to :property
	belongs_to :list_value
  has_one    :attachment, :dependent => :destroy

	validate :match_pattern
	validate :required_properties_present

  # Generally it is for File, but I have no idea how to pass it to file field only
  attr_accessor :remove
  attr_accessor :resource_type_id   
  

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

  def required_properties_present
    # debugger
    is_required(get_resource_type)
    # debugger
      # There was error on one of fields, so we need to invalidate all resource
      # Otherwise it will pass validation :(
      # errors.add(:base, "There are required fields without values")
    # end
  end

  # Validate this property to be non-empty
  # Returns 'true' on error
  def is_required(resource_type)
    result = false
    is_required = ResourceTypeProperty.is_required?(property, resource_type)
    if is_required and value.blank?
      result = true
      errors.add(:value, "of the field cannot be blank")
    end
    result
  end
    
	protected	
	
	def default_code
		code = self.property.default_code
		code.nil? ? "" : code
	end

	def match_pattern
		return if property.pattern.blank?
		
    unless value.to_s =~ Regexp.new(property.pattern, Regexp::IGNORECASE, 'u')
      errors.add(:value,
        property.pattern_text.blank? ?
        "does not match pattern /#{property.pattern}/" :
        property.pattern_text )
    end
	end
	
	def get_resource_type
	  (resource && resource.resource_type) || (resource_type_id ? (ResourceType.find(resource_type_id) rescue nil) : nil)
	end

end
