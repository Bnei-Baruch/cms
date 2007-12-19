class RpText < ResourceProperty
	
	def value
		#puts on new records the default code if exists
		super('text_value')
	end
	
	def value=(input)
		write_attribute('text_value', input)
  end
end
