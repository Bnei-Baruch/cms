class LabelType < ActiveRecord::Base
  has_many :labels
  has_many :label_type_descs, :dependent => :destroy

  attr_accessor :type_virtual

  validates_presence_of :hrid

  def self.label_types
    [["Text", "TextLabelType"], ["Number", "NumberLabelType"], ["Date", "DateLabelType"]]
  end

  def self.create(params = nil)
    class_name = params[:type_virtual] || "TextLabelType"
    class_name.constantize.new(params)
  end
  #returns the name for the label type index (doesn't put HRID if name not found)
  def name_local(lang = "eng")
    ltd = self.label_type_descs.detect {|ltd| ltd.language.abbr == lang}
    ltd ? ltd.value : ''
  end

  def name(lang = "eng")
    ltd = self.label_type_descs.detect {|ltd| ltd.language.abbr == lang}
    ltd ? ltd.value : ''
  end

  def type_short
    type.to_s.sub("LabelType",'')
  end

  def self.regular_label_types
    LabelType.find(:all, :conditions => "is_predefined = 0")
  end

  def self.predefined_label_type_id(entity)
    find_by_hrid(entity, :conditions => "is_predefined = 1")
  end
  
  protected

  def validate
    return unless lt=LabelType.find_by_hrid(hrid)
    if !self.id || self.id!=lt.id
      errors.add(:hrid, " '#{hrid}' is already being used" )
    end
  end

end


