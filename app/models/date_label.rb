class DateLabel < Label
  belongs_to :date_label_type

  def value
    self.datevalue.to_s('YYYY-MM-DD')
  end

  def value=(new_value)
    self.datevalue = Date.parse(new_value)
  end

end
