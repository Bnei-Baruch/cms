class DateLabel < Label
  belongs_to :date_label_type

  def value
    self.datevalue
  end

  def value=(new_value)
    self.datevalue = new_value
  end

end
