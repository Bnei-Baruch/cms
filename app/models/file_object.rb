class  FileObject < Item
	belongs_to :unstr_object_type, :foreign_key => :object_type_id, :class_name => "FileObjectType"

#	def file
#
#	end
#
#	def file=
#
#	end
end
