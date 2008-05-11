class RpTimestamp < ResourceProperty
	
  def value(klass = 'timestamp_value')
    #puts on new records the default code if exists
    now = super('timestamp_value')
    now.blank? ? Time.now : now
  end
	
  def value=(input)
    write_attribute('timestamp_value', input)
  end
  
  # This method is for reading values. DO NOT use for editing
  def get_value
    value
  end
  

end
