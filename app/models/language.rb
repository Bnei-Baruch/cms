class Language < ActiveRecord::Base
  belongs_to :label
  has_many :label_descs
  has_many :label_type_descs
end
