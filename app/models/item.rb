class Item < ActiveRecord::Base
	belongs_to :object_type
	has_and_belongs_to_many :labels

	def name
    self.labels.detect {|l| l.label_type_id == 38}.hrid
	end

	def name_object
    self.labels.detect {|l| l.label_type_id == 38}
	end

protected
  def self.create(object_type_id, params = nil)
		ot = ObjectType.find(object_type_id).class.to_s.sub(/Type/, '')
    class_name = ot || "ContainerObject"
    class_name.constantize.new(params)
  end


  def validate
	  if self.name == ""
      errors.add(:name, "must be supplied")
    end
#    ld = LabelDesc.find_by_label_id_and_language_id(self.label_id, self.language_id)
#    return unless ld
#    if !self.id || self.id!=ld.id
#      errors.add(:language_id, "#{self.language.label.hrid}is already being used")
#    end
  end
end
