class Property < ActiveRecord::Base 
  belongs_to :resource_type
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

# validates_uniqueness_of -- a new flag added
# :as => to report problems using an 'alias' field name instead of a real one
module ActiveRecord
	module Validations
		module ClassMethods
	
      def validates_format_of(*attr_names)
        configuration = { :message => ActiveRecord::Errors.default_error_messages[:invalid], :on => :save, :with => nil }
        configuration.update(attr_names.extract_options!)

        raise(ArgumentError, "A regular expression must be supplied as the :with option of the configuration hash") unless configuration[:with].is_a?(Regexp)

        validates_each(attr_names, configuration) do |record, attr_name, value|
					attr_alias = configuration[:as] || attr_name
          record.errors.add(attr_alias, configuration[:message]) unless value.to_s =~ configuration[:with]
        end
      end

      def validates_length_of(*attrs)
        # Merge given options with defaults.
        options = {
          :too_long     => ActiveRecord::Errors.default_error_messages[:too_long],
          :too_short    => ActiveRecord::Errors.default_error_messages[:too_short],
          :wrong_length => ActiveRecord::Errors.default_error_messages[:wrong_length]
        }.merge(DEFAULT_VALIDATION_OPTIONS)
        options.update(attrs.extract_options!.symbolize_keys)

        # Ensure that one and only one range option is specified.
        range_options = ALL_RANGE_OPTIONS & options.keys
        case range_options.size
        when 0
          raise ArgumentError, 'Range unspecified.  Specify the :within, :maximum, :minimum, or :is option.'
        when 1
          # Valid number of options; do nothing.
        else
          raise ArgumentError, 'Too many range options specified.  Choose only one.'
        end

        # Get range option and value.
        option = range_options.first
        option_value = options[range_options.first]

        case option
        when :within, :in
          raise ArgumentError, ":#{option} must be a Range" unless option_value.is_a?(Range)

          too_short = options[:too_short] % option_value.begin
          too_long  = options[:too_long]  % option_value.end

          validates_each(attrs, options) do |record, attr, value|
            attr_alias = options[:as] || attr

            if value.nil? or value.split(//).size < option_value.begin
              record.errors.add(attr_alias, too_short)
            elsif value.split(//).size > option_value.end
              record.errors.add(attr_alias, too_long)
            end
          end
        when :is, :minimum, :maximum
          raise ArgumentError, ":#{option} must be a nonnegative Integer" unless option_value.is_a?(Integer) and option_value >= 0

          # Declare different validations per option.
          validity_checks = { :is => "==", :minimum => ">=", :maximum => "<=" }
          message_options = { :is => :wrong_length, :minimum => :too_short, :maximum => :too_long }

          message = (options[:message] || options[message_options[option]]) % option_value

          validates_each(attrs, options) do |record, attr, value|
            attr_alias = options[:as] || attr
            if value.kind_of?(String)
              record.errors.add(attr_alias, message) unless !value.nil? and value.split(//).size.method(validity_checks[option])[option_value]
            else
              record.errors.add(attr_alias, message) unless !value.nil? and value.size.method(validity_checks[option])[option_value]
            end
          end
        end
      end

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
