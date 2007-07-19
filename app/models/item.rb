class Item < ActiveRecord::Base
  belongs_to :object_type
  has_many :descriptions, :dependent => :destroy
  has_many :labels, :through => :descriptions
  belongs_to :label, :foreign_key => :label_id, :class_name => "TextLabel", :dependent => :destroy

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
  
  def free_labels
    self.labels.find(:all, :conditions => "free = 1", :order => "label_order ASC")
  end
  
  def rule_labels
  	existing_labels = self.labels.find(:all, :conditions => "free = 0", :order => "label_order ASC")
  	labels = []
  	self.object_type.label_rules.each do |label_rule|
  		specific_labels = existing_labels.find_all {|l| l.label_type == label_rule.label_type }
  		unless specific_labels.empty?
  			specific_labels.each{|i| labels << i}
  			end
  		i = label_rule.occ_min - specific_labels.size
  		i.times {labels << label_rule.label_type.labels.new(:label_type_id => label_rule.label_type.id)}
  		end
  		labels
  end
  
protected
  
  def self.create(object_type_id, params = nil)
    ot = ObjectType.find(object_type_id).class.to_s.sub(/Type/, '')
    class_name = ot || "ContainerObject"
    class_name.constantize.new(params)
  end

  def check_uniq_item_labels(label)
    if self.labels.detect {|l| l.label_type_id == label.label_type_id && l.value == label.value}
      errors.add_to_base("Label of the same type with this Value is already exist in this object")
      raise ActiveRecord::RecordInvalid, self
    end
  end

  def validate
    if self.name == ""
      errors.add(:name, "must be supplied")
    end
  end


end


