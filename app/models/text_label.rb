class TextLabel < Label
  belongs_to :text_label_type
  has_one :language, :foreign_key => :label_id, :dependent => :destroy
end
