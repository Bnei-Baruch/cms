class RpNumber < ResourceProperty	

  validates_presence_of :value
  validates_numericality_of :value, :only_integer => true

  alias value_before_type_cast value

  def value
    #puts on new records the default code if exists
    super('number_value')
  end

  def value=(input)
    write_attribute('number_value', input)
  end

  def validate
#    errors.add_to_base('Test error message')
  end

end
