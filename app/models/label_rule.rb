class LabelRule < ActiveRecord::Base
  belongs_to :object_type
  belongs_to :label_type
  belongs_to :label, :foreign_key => :label_id, :class_name => "TextLabel"
  has_many :label_type_descs, :dependent => :destroy

 	def name(lang = "eng")
  	self.local_name && self.local_name.empty? ? self.label_type.name : self.local_name(lang)
  end 
  
	def local_name(lang = "eng")
		rd = self.my_label_type_descs.detect {|i| i.language.abbr == lang}
		rd ? rd.value : ''
	end

	def local_name=(new_value, lang = "eng")
		lang_obj = Language.find_by_abbr(lang)
		rd = self.my_label_type_descs.detect {|i| i.language.eql?lang_obj}
		if rd
			if new_value.empty?
				rd.destroy
			else
				rd.value = new_value
				rd.save
			end
		else
			unless new_value.empty?
				self.label_type_descs.build(
				:value => new_value,
				:language_id => lang_obj.id,
				:label_type_id => label_type_id)
			end
		end
	end
 
 def my_label_type_descs
	self.label_type_descs.find_by_label_type_id(self.label_type_id).to_a
 end
end
