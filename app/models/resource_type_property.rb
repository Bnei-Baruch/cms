class ResourceTypeProperty < ActiveRecord::Base
	belongs_to :resource_type
	belongs_to :property
  # acts_as_list
	attr_accessor :should_destroy

  def self.is_required?(property, resource_type)
    ResourceTypeProperty.find(:first, :conditions => ['resource_type_id = ? AND property_id = ?', resource_type.id, property.id]).is_required
  end
  
	def name
		local_name.blank? ? property.name : local_name
	end
	
	def data_type
		property.field_type.downcase
	end

	def should_destroy?
		should_destroy.to_i == 1
	end
end
