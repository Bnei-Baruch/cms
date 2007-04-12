class LabelTypeDesc < ActiveRecord::Base
  belongs_to :label_type
  belongs_to :language
end
