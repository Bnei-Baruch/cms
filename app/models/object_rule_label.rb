class ObjectRuleLabel < ActiveRecord::Base
  belongs_to :object_type
  belongs_to :label_type
  belongs_to :label, :foreign_key => :label_id, :class_name => "TextLabel"
end
