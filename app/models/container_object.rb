class  ContainerObject < Item
	belongs_to :container_object_type, :foreign_key => :object_type_id, :class_name => "ContainerObjectType"
end
