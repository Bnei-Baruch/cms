class LabelType < ActiveRecord::Base
  belongs_to :user
  has_many :label_type_descs
  has_many :labels
end
