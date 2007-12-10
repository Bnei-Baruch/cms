class Property < ActiveRecord::Base
	has_many :resource_type_properties, :dependent => :destroy
	has_many :resource_types, :through => :resource_type_properties
	has_many :resource_properties, :dependent => :destroy
  
	def self.types
    ['String', 'Number', 'Text', 'Date', 'List', 'File']
  end
	
	def self.properties_for_select
		find(:all).collect{|property| ["#{property.name}[#{property.field_type}]", property.id]}
  end
end