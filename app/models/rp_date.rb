class RpDate < ResourceProperty
	
	def value
		read_attribute('timestamp_value')
	end
	
	def value=(input)
		write_attribute('timestamp_value', input)
  end

end
