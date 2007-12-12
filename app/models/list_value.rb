class ListValue < ActiveRecord::Base
	has_many :resource_properties, :dependent => :destroy
	belongs_to :list
	attr_accessor :should_destroy

	def should_destroy?
		should_destroy.to_i == 1
	end

	#the date picker plugin has a bug when working with real date variable
	def fixed_date_value
		read_attribute('date_value') if date_value
	end

	def fixed_date_value=(input)
		write_attribute('date_value', input)
	end
	
	def value
		eval "#{list.list_type.downcase}_value"
	end

end
