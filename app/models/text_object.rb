class  TextObject < Item
	belongs_to :unstr_object_type, :foreign_key => :object_type_id, :class_name => "TextObjectType"

#	def file
#
#	end
#
#	def file=
#
#	end
end
