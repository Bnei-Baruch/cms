class Resource < ActiveRecord::Base
	has_and_belongs_to_many :websites
	belongs_to :resource_type
	has_many :resource_properties, :dependent => :destroy
	has_many :rp_number_properties, :class_name => 'RpNumber', :dependent => :destroy
	has_many :rp_string_properties, :class_name => 'RpString', :dependent => :destroy
	has_many :rp_text_properties, :class_name => 'RpText', :dependent => :destroy
	has_many :rp_plaintext_properties, :class_name => 'RpPlaintext', :dependent => :destroy
	has_many :rp_timestamp_properties, :class_name => 'RpTimestamp', :dependent => :destroy
	has_many :rp_date_properties, :class_name => 'RpDate', :dependent => :destroy
	has_many :rp_boolean_properties, :class_name => 'RpBoolean', :dependent => :destroy
	has_many :rp_list_properties, :class_name => 'RpList', :dependent => :destroy

	after_update :save_resource_properties

	def name
		eval calculate_name_code(resource_type.name_code)
	end

	def my_properties=(my_properties)
		my_properties.each_with_index do |p, i|
			more_properties = {:position => i +1}
			h = p.merge!(more_properties)
			if h[:id].blank?
				eval "#{h[:property_type].underscore}_properties.build(h)"
			else
				resource_property = resource_properties.detect{|rp|
					rp.id == h[:id].to_i}
				resource_property.attributes = h
			end
		end
	end

	def get_resource_property_by_resource_type_property(rtp) #rtp = resource_type_property
		get_resource_property_by_property(rtp.property)
	end

	private

	def get_resource_property_by_property_hrid(hrid)
		begin
			property = resource_type.properties.find_by_hrid(hrid)
			return get_resource_property_by_property(property).value
		rescue
			''
		end
	end

	def get_resource_property_by_property(property) #rtp = resource_type_property
		if new_record? || 
				resource_properties.empty? || 
				!(obj = eval "Rp#{property.field_type.camelize}.find_by_resource_id_and_property_id(id,property.id)")
			rp = eval "rp_#{property.field_type.downcase}_properties.new"
			rp.resource = self
			rp.property = property
		else
			rp = obj
		end
		return rp
	end

	def save_resource_properties
		resource_properties.each do |rp|
			rp.save(false)
		end
	end
		
	def calculate_name_code(name_code)
		name_code.gsub(/<([^>]*?)>/) do |match|
			"'#{get_resource_property_by_property_hrid($1)}'"
		end
	end
	
end
