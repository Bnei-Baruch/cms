class DateLabelType < LabelType
  has_many :labels, :foreign_key => :label_type_id, :class_name => "DateLabel", :dependent => :destroy
end
