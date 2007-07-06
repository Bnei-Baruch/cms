class ObjectRuleLabel < ActiveRecord::Base
  belongs_to :object_type
  belongs_to :label_type
  belongs_to :label, :foreign_key => :label_id, :class_name => "TextLabel"
  has_many :label_type_descs, :dependent => :destroy
end
