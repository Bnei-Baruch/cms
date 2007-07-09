class LabelRule < ActiveRecord::Base
  belongs_to :object_type
  belongs_to :label_type
  belongs_to :label, :foreign_key => :label_id, :class_name => "TextLabel"
  has_many :label_type_descs, :dependent => :destroy
  
  
#  def local_name(lang = "eng")
#    rd = self.label_type_descs.detect {|rd| rd.language.abbr == lang}
#    rd ? rd.value : ''
#  end
#
#  def local_name=(new_value, lang = "eng")
#    lang_obj = Language.find_by_abbr(lang)
#    rd = self.label_type_descs.detect {|ltd| ltd.language.eql?lang_obj}
#    if rd
#      rd.value = new_value
#      rd.save
#    else
#      rd = label_type_descs.create(
#      :value => new_value,
#      :language_id => lang_obj.id)
#    end
#  end
end
