class TextLabelType < LabelType
  has_many :labels, :foreign_key => :label_type_id, :class_name => "TextLabel", :dependent => :destroy
end
