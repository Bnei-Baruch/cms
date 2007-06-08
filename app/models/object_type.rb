class ObjectType < ActiveRecord::Base
  has_many :objects, :class_name => "Item"
  belongs_to :label, :foreign_key => :label_id, :class_name => "TextLabel"

  attr_accessor :type_virtual

  validates_presence_of :hrid
  #validates_uniqueness_of :hrid - moved to validate

  def self.create(params = nil)
    class_name = params[:type_virtual] || "ContainerObjectType"
    class_name.constantize.new(params)
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
