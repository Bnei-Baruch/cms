class NumberLabel < Label
  belongs_to :number_label_type

  validates_presence_of :numbervalue
  validates_numericality_of :numbervalue

  def value
    self.numbervalue
  end



end
