class TextLabel < Label
  belongs_to :text_label_type
  has_one :language, :foreign_key => :label_id, :dependent => :destroy
  has_one :object_type, :foreign_key => :label_id, :dependent => :destroy
  has_many :label_descs, :foreign_key => "label_id", :dependent => :destroy
  has_many :objects, :foreign_key => "label_id", :dependent => :destroy

  validates_associated :label_descs, :message => "value is invalid", :on => :save

  def value(lang = "eng")
    ld = self.label_descs.detect {|ld| ld.language.abbr == lang}
    ld ? ld.value : ''
  end

  def value=(new_value, lang = "eng")
    lang_obj = Language.find_by_abbr(lang)
    ld = self.label_descs.detect {|ltd| ltd.language.eql?lang_obj}
    if ld
      ld.value = new_value
      ld.save
    else
      ld = label_descs.create(
        :value => new_value,
        :language_id => lang_obj.id)
    end
	end

	private

end
