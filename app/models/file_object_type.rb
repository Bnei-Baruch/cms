class FileObjectType < ObjectType
  has_many :objects, :foreign_key => :object_type_id, :class_name => "FileObject", :dependent => :destroy


end
