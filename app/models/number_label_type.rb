class NumberLabelType < LabelType
  has_many :labels, :foreign_key => :label_type_id, :class_name => "NumberLabel", :dependent => :destroy
end
