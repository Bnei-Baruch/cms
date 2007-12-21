class RpTimestamp < ResourceProperty
	
  def value(klass = 'timestamp_value')
    #puts on new records the default code if exists
    super('timestamp_value')
  end
	
  def value=(input)
    write_attribute('timestamp_value', input)
  end

end
