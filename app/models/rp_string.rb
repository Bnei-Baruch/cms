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

end
