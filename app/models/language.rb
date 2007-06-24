class Language < ActiveRecord::Base
  belongs_to :label, :foreign_key => :label_id, :class_name => "TextLabel"
  has_many :label_type_descs

  validates_presence_of :abbr
  validates_uniqueness_of :abbr
  validates_length_of :abbr, :is => 3

  def name(lang = "eng")
    label.value(lang)
  end

  def self.predefined_label_type
    LabelType.predefined_label_type_id(self.to_s).id
  end

  protected

  def after_destroy
    self.label.destroy
  end


end
