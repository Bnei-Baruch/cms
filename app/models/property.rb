class Property < ActiveRecord::Base
	has_many :resource_type_properties, :dependent => :destroy
	has_many :resource_types, :through => :resource_type_properties
	has_many :resource_properties, :dependent => :destroy
	belongs_to :list

  # We'd like to report problems of HRID as if it was called IDENTIFIER
	alias_attribute :identifier, :hrid 

  # Perform the necessary validations
	validates_presence_of :name
	validate	:presence_of_hrid # This permits us to report :identifier instead of
                              # :hrid without rewriting functions
	validates_uniqueness_of :name
	validates_uniqueness_of :hrid, :as => :identifier # The function was rewritten 
                                                    # (new flag :as was added)
	validate :correctness_of_default_code
	
	def self.types
		['String', 'Number', 'Boolean', 'Text', 'Plaintext', 'Timestamp', 'Date', 'List', 'File']
	end
	
	def self.properties_for_select
		find(:all).map{|property| ["#{property.name}(#{property.hrid})[#{property.field_type}]", property.id]}
	end
  
	def self.get_property_by_hrid(identifier)
		Property.find_by_hrid(identifier)
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
			eval(default_code, binding, "property", 1)
		rescue Exception => e
			errors.add(:default_code, "-- an error occurred:<br/> #{$!}")
		end
	end
	
end

# validates_uniqueness_of -- a new flag added
# :as => to report problems using an 'alias' field name instead of a real one
module ActiveRecord
	module Validations
		module ClassMethods
	
			def validates_uniqueness_of(*attr_names)
				configuration = { :message => ActiveRecord::Errors.default_error_messages[:taken], :case_sensitive => true }
				configuration.update(attr_names.extract_options!)

				validates_each(attr_names,configuration) do |record, attr_name, value|
          # Here we decide between original name and a given alias
          # It is used at the very end of the function
					attr_alias = configuration[:as] || attr_name

					if value.nil? || (configuration[:case_sensitive] || !columns_hash[attr_name.to_s].text?)
						condition_sql = "#{record.class.table_name}.#{attr_name} #{attribute_condition(value)}"
						condition_params = [value]
					else
						condition_sql = "LOWER(#{record.class.table_name}.#{attr_name}) #{attribute_condition(value)}"
						condition_params = [value.downcase]
					end

					if scope = configuration[:scope]
						Array(scope).map do |scope_item|
							scope_value = record.send(scope_item)
							condition_sql << " AND #{record.class.table_name}.#{scope_item} #{attribute_condition(scope_value)}"
							condition_params << scope_value
						end
					end

					unless record.new_record?
						condition_sql << " AND #{record.class.table_name}.#{record.class.primary_key} <> ?"
						condition_params << record.send(:id)
					end

					# The check for an existing value should be run from a class that
					# isn't abstract. This means working down from the current class
					# (self), to the first non-abstract class. Since classes don't know
					# their subclasses, we have to build the hierarchy between self and
					# the record's class.
					class_hierarchy = [record.class]
					while class_hierarchy.first != self
						class_hierarchy.insert(0, class_hierarchy.first.superclass)
					end

					# Now we can work our way down the tree to the first non-abstract
					# class (which has a database table to query from).
					finder_class = class_hierarchy.detect { |klass| !klass.abstract_class? }

					if finder_class.find(:first, :conditions => [condition_sql, *condition_params])
						record.errors.add(attr_alias, configuration[:message])
					end
				end
			end
		end
	end
end
