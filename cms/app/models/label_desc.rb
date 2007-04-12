class LabelDesc < ActiveRecord::Base
  belongs_to :language
  belongs_to :label
end
