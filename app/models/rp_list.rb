class RpList < ResourceProperty
	belongs_to :list_value
	attr_accessor :list_type

	def value
		#		if self.new_record?
		#			@value
		#		else
		case self.property.list.list_class
		when 's' #Simple list type
			read_attribute('list_value_id')
		when 'r' #Resource list type
			read_attribute('resource_as_property_id')
		when 'rp' #Resource property list type
			read_attribute('resource_property_id')
		end
		#		end
	end

	def value=(input)
		case self.property.list.list_class
		when 's' #Simple list type
			write_attribute('list_value_id', input)
		when 'r' #Resource list type
			write_attribute('resource_as_property_id', input)
		when 'rp' #Resource property list type
			write_attribute('resource_property_id', input)
		end
	end
	
	# This method is for reading values. DO NOT use for editing
  def get_value
    value
  end
	

end
