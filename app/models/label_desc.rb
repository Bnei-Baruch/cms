class LabelDesc < ActiveRecord::Base
  belongs_to :label, :class_name=> "TextLabel", :foreign_key => "label_id"
  belongs_to :language

  validates_presence_of :value, :message => "Label's value must not be empty"

  def validate
    ld = LabelDesc.find_by_label_id_and_language_id(self.label_id, self.language_id)
    return unless ld
    if !self.id || self.id!=ld.id
      errors.add(:language_id, "#{self.language.label.hrid}is already being used")
    end
  end

end
