class RpNumber < ResourceProperty	
	def validate
#		errors.add_to_base("Value: msg")
		errors.add(:value, "is missing or invalid" )
	end

	def value
		read_attribute('number_value')
	end
	
	def value=(input)
		write_attribute('number_value', input)
  end

end
