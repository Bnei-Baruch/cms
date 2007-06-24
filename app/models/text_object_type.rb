class TextObjectType < ObjectType
  has_many :objects, :foreign_key => :object_type_id, :class_name => "TextObject", :dependent => :destroy
end
