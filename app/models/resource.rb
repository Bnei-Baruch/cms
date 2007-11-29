class Resource < ActiveRecord::Base
	has_and_belongs_to_many :websites
	belongs_to :resource_type
	has_many :resource_properties, :dependent => :destroy
	has_many :rp_number_properties, :class_name => 'RpNumber', :dependent => :destroy
	has_many :rp_string_properties, :class_name => 'RpString', :dependent => :destroy
	has_many :rp_text_properties, :class_name => 'RpText', :dependent => :destroy
	has_many :rp_date_properties, :class_name => 'RpDate', :dependent => :destroy
	
	after_update :save_resource_properties
	
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
	
	def get_property(rtp) #rtp = resource_type_property
		if new_record? || 
				resource_properties.empty? || 
				!(obj = eval "Rp#{rtp.data_type.camelize}.find_by_resource_id_and_property_id(id,rtp.property.id)")
			rp = eval "rp_#{rtp.data_type.downcase}_properties.new"
			rp.resource = self
			rp.property = rtp.property
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
	
end
