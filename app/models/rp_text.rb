class RpText < ResourceProperty
	
	def value
		read_attribute('text_value')
	end
	
	def value=(input)
		write_attribute('text_value', input)
  end
end
