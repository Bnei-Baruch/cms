class RpString < ResourceProperty

	def value
		read_attribute('string_value')
	end
	
	def value=(input)
		write_attribute('string_value', input)
  end

end
