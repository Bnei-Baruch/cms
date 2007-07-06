class LabelTypeDesc < ActiveRecord::Base
  belongs_to :label_type
  belongs_to :language
  belongs_to :object_rule_label
 
  validates_presence_of :value

  protected

  def validate
    ltd = LabelTypeDesc.find_by_label_type_id_and_language_id_and_object_rule_label_id(self.label_type_id, self.language_id, self.object_rule_label_id)
    return unless ltd
    if !self.id || self.id!=ltd.id
      errors.add_to_base("self=#{self.id}ltd=#{ltd.id}The combination of Language (#{self.language.label.hrid}) + Object Rule (#{self.object_rule_label_id || 'null'}) of the label type -<b>#{self.label_type.hrid}</b> is already being used")
    end
  end
end