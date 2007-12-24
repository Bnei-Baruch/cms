class ResourceType < ActiveRecord::Base
	has_and_belongs_to_many :websites
	has_many :resource_type_properties, :order => :position, :dependent => :destroy
	has_many :associations, :order => :position, :foreign_key => :parent_id, :dependent => :destroy
	has_many :properties, :through => :resource_type_properties
	has_many :resources, :dependent => :destroy
	has_many :lists, :dependent => :destroy
	
	after_update :save_resource_type_properties, :save_associations

  # We'd like to report problems with HRID as if it's name was IDENTIFIER
	alias_attribute :identifier, :hrid
  
	validates_presence_of :name, :identifier, :name_code
	validates_uniqueness_of :name
	validates_uniqueness_of :hrid, :as => :identifier
	validate :correctness_of_name_code  # TODO: not implemented, see below

	def my_properties=(my_properties)
		my_properties.each_with_index do |p, i|
			more_properties = {:position => i +1}
			h = p.merge!(more_properties)
			if h[:id].blank?
				resource_type_properties.build(h)
			else
				resource_type_property = resource_type_properties.detect{|rtp| rtp.id == h[:id].to_i}
				resource_type_property.attributes = h
			end
    end
  end

	def my_associations=(my_associations)
		my_associations.each_with_index do |p, i|
			more_properties = {:position => i +1}
			h = p.merge!(more_properties)
			if h[:id].blank?
				associations.build(h)
			else
				association = associations.detect{|rtp| rtp.id == h[:id].to_i}
				association.attributes = h
			end
    end
  end
	
	def self.resource_types_for_select
		find(:all).collect{|rt| [rt.name, rt.id]}.sort
	end
	
	def get_associations
		Association.find_all_by_parent_id(self.id)
	end
	
	def resource_types_for_association_select
		(ResourceType.find(:all) - get_associations).collect{|resource_type| [resource_type.name, resource_type.id]}
	end
	
	def resource_type_properties_for_select
		resource_type_properties.collect{|e| [e.name, e.property.id]}
	end
	
	protected
	
	def correctness_of_name_code
    # calculate_name_code should be accessible from here, but it is not public :(
#		begin
#			eval(Resource.calculate_name_code(name_code), binding, "property", 1)
#		rescue Exception => e
#			errors.add(:name_code, "-- an error occurred:<br/> #{$!}")
#		end
	end
	
	private
	
	def save_resource_type_properties
		resource_type_properties.each do |rtp|
			if rtp.should_destroy?
				rtp.destroy
			else
				rtp.save(false)
      end
			
    end
	end

	def save_associations
		associations.each do |ass|
			if ass.should_destroy?
				ass.destroy
			else
				ass.save(false)
      end
			
    end
	end
	
end
