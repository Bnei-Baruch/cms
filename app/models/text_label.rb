class TextLabel < Label
  belongs_to :text_label_type
  has_one :language, :foreign_key => :label_id, :dependent => :destroy
  has_one :object_type, :foreign_key => :label_id, :dependent => :destroy
  has_many :label_descs, :foreign_key => "label_id", :dependent => :destroy

  def value
    self.hrid
  end

end
