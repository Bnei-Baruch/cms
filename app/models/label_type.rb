class LabelType < ActiveRecord::Base
  has_many :labels

  attr_accessor :type_virtual

  validates_presence_of :hrid
  #validates_uniqueness_of :hrid - moved to validate

  def self.create(params = nil)
    class_name = params[:type_virtual] || "TextLabelType"
    class_name.constantize.new(params)
  end

  protected

  def validate
    if LabelType.find_by_hrid(hrid)
      errors.add(:hrid, " '#{hrid}' is already being used" )
    end
  end

end
