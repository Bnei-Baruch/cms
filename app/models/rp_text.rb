class RpText < ResourceProperty
	
	def value
		#puts on new records the default code if exists
		super('text_value')
	end
	
	def value=(input)
		write_attribute('text_value', input)
  end
  
  # This method is for reading values. DO NOT use for editing
  def get_value
    read_attribute('text_value')
  end
  
end
