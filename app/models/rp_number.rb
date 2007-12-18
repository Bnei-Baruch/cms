class RpNumber < ResourceProperty	
	
	def value
		#puts on new records the default code if exists
		get_value('number_value')
	end
	
	def value=(input)
		write_attribute('number_value', input)
	end

	def validate
		errors.add_to_base('test number')
	end
	
end
