class DateLabel < Label
  belongs_to :date_label_type

  def value
    self.datevalue
  end

end
