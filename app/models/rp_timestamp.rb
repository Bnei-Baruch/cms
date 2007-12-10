class RpTimestamp < ResourceProperty
	
	def value
		#puts on new records the default code if exists
		if self.new_record? && (default_code = self.property.default_code)
			eval default_code
		else
			read_attribute('timestamp_value')
		end
	end
	
	def value=(input)
		write_attribute('timestamp_value', input)
  end

end