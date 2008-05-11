class RpString < ResourceProperty
	belongs_to :resource
	belongs_to :property

	def value
		#puts on new records the default code if exists
		super('string_value')
	end
	
	def value=(input)
		write_attribute('string_value', input)
  end
    
  # This method is for reading values. DO NOT use for editing
  def get_value
    read_attribute('string_value')
  end

end
