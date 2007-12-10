class List < ActiveRecord::Base
	has_many :list_values, :dependent => :destroy
	after_update :save_list_values
	has_many :properties
	
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
		['String', 'Number', 'Text', 'Date', 'Resource', 'RescourceProperty']
	end

	def self.types_for_select
		self.types.collect { |e| [e, e.underscore] }
  end
end

def save_list_values
	list_values.each do |e|
		if e.should_destroy?
			e.destroy
		else
			e.save(false)
		end
			
	end
end
