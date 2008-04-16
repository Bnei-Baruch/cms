class RpDate < RpTimestamp
	
	def value
		#puts on new records the default code if exists
		timestamp_value ? super('timestamp_value').to_date : ""
	end
	
	def value=(input)
		write_attribute('timestamp_value', input)
	end

end
