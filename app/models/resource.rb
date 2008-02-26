class Resource < ActiveRecord::Base
	has_and_belongs_to_many :websites
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
	has_many :tree_nodes, :dependent => :destroy
	
	attr_accessor :tree_node 
	
	#only associate resources of the type 'website'
	has_one :website, :foreign_key => 'entry_point_id'
  
  after_update :save_resource_properties
	after_create :create_tree_node
  before_destroy :nullify_website_if_exists

  # Let each property of the Resource to validate itself
	validates_associated :resource_properties
  
  validate :required_properties_present
	
	def name
		eval calculate_name_code(resource_type.name_code)
	end

	def my_properties=(my_properties)
		my_properties.each_with_index do |p, i|
			more_properties = {:position => i + 1}
			p.merge!(more_properties)
			if p[:id].blank?
        p = Attachment.store_rp_file(nil, p) if p[:property_type] == "RpFile"
        resource_property = self.send("#{p[:property_type].underscore}_properties").send(:build, p)
			else
        resource_property = resource_properties.detect{|rp|
          rp.id == p[:id].to_i
        }
        p = Attachment.store_rp_file(resource_property, p) if p[:property_type] == "RpFile"
        resource_property.attributes = p
			end
		end
	end

	def get_resource_property_by_resource_type_property(rtp) #rtp = resource_type_property
		get_resource_property_by_property(rtp.property)
	end

  protected

  def nullify_website_if_exists
    if website && resource_type_id == Website.get_website_resource_type.id
      website.nullify_website_resource
    end
  end
  
  # We cannot call this directly in property, because we don't know there resource_type
  def required_properties_present
    result = false
		resource_properties.each do |rp|
      result ||= rp.is_required(resource_type)
    end
    if result
      # There was error on one of fields, so we need to invalidate all resource
      # Otherwise it will pass validation :(
      errors.add(:base, "There are required fields without values")
    end
  end

	def get_resource_property_by_property_hrid(hrid)
		begin
			property = resource_type.properties.find_by_hrid(hrid)
			return get_resource_property_by_property(property).value
		rescue
			''
		end
	end

	def calculate_name_code(name_code)
		name_code.gsub(/<([^>]*?)>/) do |match|
			"'#{get_resource_property_by_property_hrid($1)}'"
		end
	end
	
	def get_resource_property_by_property(property) #rtp = resource_type_property
		resource_property_array = eval("rp_#{property.field_type.downcase}_properties") || []

		if new_record? #new or not validated new
			if resource_property_array.empty? #new before validation
				rp = eval "rp_#{property.field_type.downcase}_properties.new"
				rp.resource = self
				rp.property = property
			else #not valid new
				rp = resource_property_array.detect { |e| e.property_id == property.id }
				rp.resource = self
				rp.property = property
      end
		else #edit or not validated edit
			rp = resource_properties.detect { |e| e.property_id == property.id }
			if rp.nil?
				rp = resource_property_array.detect { |e| e.property_id == property.id } || (eval "Rp#{property.field_type.camelize}.new")
				rp.resource = self
				rp.property = property
      end
		end
		return rp
	end

	def save_resource_properties
		resource_properties.each do |rp|
			rp.save(false)
		end
	end
	
	# Creates tree node if the resource was created with hierarchy
	def create_tree_node
		if self.tree_node
			new_node = TreeNode.new(self.tree_node)
			new_node.resource = self
			new_node.save!
		end
	end
		
end
