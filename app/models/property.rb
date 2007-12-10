class Property < ActiveRecord::Base
	has_many :resource_type_properties, :dependent => :destroy
	has_many :resource_types, :through => :resource_type_properties
	has_many :resource_properties, :dependent => :destroy
  belongs_to :list
	
	def self.types
    ['String', 'Number', 'Boolean', 'Text', 'Timestamp', 'Date', 'List', 'File']
  end
	
	def self.properties_for_select
		find(:all).collect{|property| ["#{property.name}(#{property.hrid})[#{property.field_type}]", property.id]}
  end
  
  def self.get_property_by_hrid(identifier)
		Property.find_by_hrid(identifier)
  end
end
