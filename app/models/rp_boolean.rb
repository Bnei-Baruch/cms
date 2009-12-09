class RpBoolean < ResourceProperty	

  def value
    #puts on new records the default code if exists
    super('boolean_value')
  end
	
  def value=(input)
    write_attribute('boolean_value', (input == 't') || (input == 'true') )
  end

	# This method is for reading values. DO NOT use for editing
  def get_value
    read_attribute('boolean_value')
  end

end
