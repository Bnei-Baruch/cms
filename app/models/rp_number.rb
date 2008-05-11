class RpNumber < ResourceProperty	

  validates_numericality_of :value, :only_integer => true, :allow_nil => true
	
  # validates_numericality_of requires presence of the following function
  alias value_before_type_cast value

  def value
    #puts on new records the default code if exists
    super('number_value')
  end

  def value=(input)
    write_attribute('number_value', input)
  end
  
  # This method is for reading values. DO NOT use for editing
  def get_value
    read_attribute('number_value')
  end

end
