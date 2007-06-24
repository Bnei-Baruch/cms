class ContainerObjectType < ObjectType
  has_many :objects, :foreign_key => :object_type_id, :class_name => "ContainerObject", :dependent => :destroy
end
