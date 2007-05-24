class LabelType < ActiveRecord::Base
  attr_accessor :type_virtual

  def self.create(params = nil)
    class_name = params[:type_virtual] || "TextLabelType"
    class_name.constantize.new(params)
  end
end
