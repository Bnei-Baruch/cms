class ObjectType < ActiveRecord::Base
  has_many :objects, :class_name => "Item", :dependent => :destroy
  has_many :label_rules, :dependent => :destroy
  belongs_to :label, :foreign_key => :label_id, :class_name => "TextLabel"

  attr_accessor :type_virtual

  validates_presence_of :hrid
  #validates_uniqueness_of :hrid - moved to validate
  validates_associated :label, :message => "Name is invalid", :on => :save

  validates_associated :label_rules, :message => "are messed up"
  def self.create(params = nil)
    class_name = params[:type_virtual] || "ContainerObjectType"
    class_name.constantize.new(params)
  end
	
	def self.object_types
		[["Container", "ContainerObjectType"],["Text", "TextObjectType"],["File", "FileObjectType"]]
	end
  def self.predefined_label_type
    LabelType.predefined_label_type_id(self.to_s).id
  end

  def name(lang ="eng")
    label.value(lang)
  end

  def type_short
    type.to_s.sub("ObjectType",'')
  end

  def self.get_label_type_name (object_type_id, label, rule_or_free = "free")
  	return_value = nil
		object_type = find(object_type_id)
		if rule_or_free == "rule" && object_type.label_rules
	  	object_type.label_rules.each do |lr|
				return_value = lr.name if label.label_type.eql?lr.label_type
			end
		end
		return_value = label.label_type.name unless return_value
		return_value
  end

  protected

  def validate
    return unless ot=ObjectType.find_by_hrid(hrid)
    if !self.id || self.id!=ot.id
      errors.add(:hrid, " '#{hrid}' is already being used" )
    end
  end

  def after_destroy
    self.label.destroy
  end
end
