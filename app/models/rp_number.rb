class RpNumber < ResourceProperty	

	def value
		read_attribute('number_value')
	end
	
	def value=(input)
		write_attribute('number_value', input)
  end

end
