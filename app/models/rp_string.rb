class RpString < ResourceProperty
	belongs_to :resource
	belongs_to :property

	def value
		#puts on new records the default code if exists
		if self.new_record? && (default_code = self.property.default_code)
			eval default_code
		else
			read_attribute('string_value')
		end
	end
	
	def value=(input)
		write_attribute('string_value', input)
  end

end
