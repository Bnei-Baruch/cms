class Property < ActiveRecord::Base 
  belongs_to :resource_type
	has_many :resource_properties, :dependent => :destroy
  has_many :rp_number_properties, :class_name => 'RpNumber', :dependent => :destroy
  has_many :rp_string_properties, :class_name => 'RpString', :dependent => :destroy
  has_many :rp_text_properties, :class_name => 'RpText', :dependent => :destroy
  has_many :rp_plaintext_properties, :class_name => 'RpPlaintext', :dependent => :destroy
  has_many :rp_timestamp_properties, :class_name => 'RpTimestamp', :dependent => :destroy
  has_many :rp_date_properties, :class_name => 'RpDate', :dependent => :destroy
  has_many :rp_boolean_properties, :class_name => 'RpBoolean', :dependent => :destroy
  has_many :rp_file_properties, :class_name => 'RpFile', :dependent => :destroy
  has_many :rp_list_properties, :class_name => 'RpList', :dependent => :destroy

	belongs_to :list

  # We'd like to report problems of HRID as if it was called IDENTIFIER
	alias_attribute :identifier, :hrid 

  # Perform the necessary validations
	validates_presence_of :name
	validate	:presence_of_hrid # This permits us to report :identifier instead of
  # :hrid without rewriting functions
	validates_uniqueness_of :name, :scope => :resource_type_id
	validates_uniqueness_of :hrid, :scope => :resource_type_id
	validate :correctness_of_default_code

  # We need to save old geometry and to update thumbnails accordingly
  attr_accessor :old_geometry
	attr_accessor :should_destroy
	
	TYPES = ['String', 'Number', 'Boolean', 'Text', 'Plaintext', 'Timestamp', 'Date', 'List', 'File']
  
	def self.types
		TYPES
	end
	
	def self.types_for_select
		types.map{|type| [type, type]}
	end
	
	
  # DEPRICATED
	def self.properties_for_select
		find(:all).map{|property| ["#{property.name}(#{property.hrid})[#{property.field_type}]", property.id]}
	end
    
	def self.get_property_by_hrid(identifier)
		Property.find_by_hrid(identifier)
	end
  
  # DEPRICATED
	def data_type
		property.field_type.downcase
	end

	def should_destroy?
		should_destroy.to_i == 1
	end
	
	protected
	
  # HRID must present
	def presence_of_hrid
		errors.add(:identifier, ActiveRecord::Errors.default_error_messages[:blank]) if hrid.blank?
	end

  # default_code must be a valid Ruby code
	def correctness_of_default_code
		return if default_code.blank?
    
		begin
			eval(default_code, binding, "Property validation", 1)
		rescue Exception => e
      error_text = $!
			errors.add(:default_code, "-- an error occurred:<br/> #{error_text}")
		end
	end
end
