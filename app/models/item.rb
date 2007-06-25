class Item < ActiveRecord::Base
	belongs_to :object_type
	has_and_belongs_to_many :labels, :before_add => :check_uniq_item_labels
  belongs_to :label, :foreign_key => :label_id, :class_name => "TextLabel"


  attr_accessor :label_type_id

	def attrs
    labels = self.labels.select {|l| l.label_type_id != Item.predefined_label_type.id}
    labels ? labels : []
	end

	def name
	  self.label ? self.label.value : ""
	end

  def self.predefined_label_type
    LabelType.predefined_label_type_id(self.to_s)
  end

  def type_short
    type.to_s.sub("Object",'')
  end

protected
  def self.create(object_type_id, params = nil)
		ot = ObjectType.find(object_type_id).class.to_s.sub(/Type/, '')
    class_name = ot || "ContainerObject"
    class_name.constantize.new(params)
  end

  def check_uniq_item_labels(label)
      if self.labels.detect {|l| l.id == label.id}
  	      errors.add_to_base("Label with this HRID (ID:#{label.id}) is already exist in this object")
	      raise ActiveRecord::RecordInvalid, self
	    end
	    if self.labels.detect {|l| l.label_type_id == label.label_type_id && l.value == label.value}
  	      errors.add_to_base("Label of the same type with this Value is already exist in this object")
	      raise ActiveRecord::RecordInvalid, self
	    end
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


