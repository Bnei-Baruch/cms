class List < ActiveRecord::Base
	has_many			:list_values, :dependent => :destroy
	has_many			:properties, :dependent => :destroy
	belongs_to		:resource_type
	after_update	:save_list_values
	belongs_to		:property

  # Validate name here, but pass values to validate themselves
	validates_presence_of :name
	validates_uniqueness_of :name
  validates_associated :list_values

	def my_list_values=(my_list_values)
		my_list_values.each do |p|
			if p[:id].blank?
				list_values.build(p)
			else
				list_value = list_values.detect{|e| e.id == p[:id].to_i}
				list_value.attributes = p
			end
		end
	end

	def self.types
		['String', 'Number', 'Text', 'Date', 'Resource', 'ResourceProperty']
	end

	def self.types_for_select
		self.types.collect { |e| [e, e.underscore] }
	end

	def self.names_for_select
		find(:all).collect{|e| [e.name, e.id]}
	end

	#used in rp_list.rb model to know which type is this list:
	#s  - simple
	#r  - resource
	#rp - resource_property
	def list_class
		if self.resource_type_id
			if self.property_id
				return 'rp'
			else
				return 'r'
			end
		else
			return 's'
		end
	end
	
	def values_for_select
		if self.resource_type_id
			if self.property_id
				list_values.collect{|e| [e.value, e.id]}
			else
				resource_type.resources.collect{|e| [e.name, e.id]}
      end
		else
			list_values.collect{|e| [e.value, e.id]}
    end
	end

	private
	
	def save_list_values
		list_values.each do |e|
			if e.should_destroy?
				e.destroy
			else
				e.save(false)
			end
		end
	end
end

