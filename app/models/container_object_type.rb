class ContainerObjectType < ObjectType
  has_many :objects, :foreign_key => :object_id, :class_name => "ContainerObject", :dependent => :destroy
end
