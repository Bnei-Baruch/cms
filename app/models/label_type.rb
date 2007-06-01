class LabelType < ActiveRecord::Base
  has_many :labels
  has_many :label_type_descs, :dependent => :destroy

  attr_accessor :type_virtual

  validates_presence_of :hrid
  #validates_uniqueness_of :hrid - moved to validate

  def self.create(params = nil)
    class_name = params[:type_virtual] || "TextLabelType"
    class_name.constantize.new(params)
  end

  protected

  def validate
    return unless lt=LabelType.find_by_hrid(hrid)
    if !self.id || self.id!=lt.id
      errors.add(:hrid, " '#{hrid}' is already being used" )
    end
  end

end
