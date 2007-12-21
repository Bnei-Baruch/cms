class RpBoolean < ResourceProperty	

  def value
    #puts on new records the default code if exists
    super('boolean_value')
  end
	
  def value=(input)
    write_attribute('boolean_value', input)
  end

end
