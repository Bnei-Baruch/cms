class LabelType < ActiveRecord::Base
  has_many :labels

  attr_accessor :type_virtual

  validates_presence_of :hrid
  validates_uniqueness_of :hrid

  def self.create(params = nil)
    class_name = params[:type_virtual] || "TextLabelType"
    class_name.constantize.new(params)
  end
end
