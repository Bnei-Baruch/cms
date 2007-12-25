require 'uri'

class Website < ActiveRecord::Base
	has_and_belongs_to_many :resources	
	has_and_belongs_to_many :resource_types

  validates_presence_of :name
	validates_uniqueness_of :name 
  validate :correctness_of_domain_and_prefix
  
	def self.associate_website(object, website_id)
    # put website from session to resource
		if website_id && (website = Website.find(website_id))
			if object.new_record? || (not object.new_record?) && ((not (websites = object.websites)) || websites && (not websites.include?(website)))
				object.websites << website
			end
		end
	end
	
	def get_website_resources
		resource_type = ResourceType.find_by_hrid('website')
		resource_type.resources
	end

  protected
  
  def correctness_of_domain_and_prefix
    # no slashes on the end of domain and the start and end of prefix
		errors.add(:domain, 'must has no slashes on the end of domain') if domain =~ /\A.+\/\Z/
		errors.add(:prefix, 'must has no slashes at the start and/or end of prefix') if prefix =~ /\A(\/.+)|(.+\/)\Z/
    domain.gsub!(/[^:]\/\//, '/')
    prefix.gsub!(/\/\//, '/')

    url = domain + "/" + prefix
    url.gsub!(/[^:]\/\//, '/')
    if url.blank?
			errors.add(:domain_and_prefix, ActiveRecord::Errors.default_error_messages[:empty])
			return
    end

    # validates_format_of domain
    begin
			uri = URI(domain)
		rescue Exception => ex
			errors.add(:domain, "#{ActiveRecord::Errors.default_error_messages[:invalid]}: #{$!}")
      return
		end
    unless (['HTTP','HTTPS'].include?(uri.scheme.upcase))
      errors.add(:domain, "bad scheme component: #{uri.scheme}")
      return
    end

    # validates_format_of url
		begin
			uri = URI("#{url}/")
		rescue Exception => ex
			errors.add(:domain_and_prefix, "#{ActiveRecord::Errors.default_error_messages[:invalid]}: #{$!}")
		end
    unless (['HTTP','HTTPS'].include?(uri.scheme.upcase))
      errors.add(:domain_and_prefix, "bad scheme component: #{uri.scheme}")
      return
    end

    # validates_uniqueness_of url
    sites = Website.find(:all, :conditions => ['domain = ? AND prefix = ?', domain, prefix])
    sites.reject! { |site| site.id == id } unless sites.empty?
    errors.add(:domain_and_prefix, ActiveRecord::Errors.default_error_messages[:taken]) unless sites.empty?
  end

	def get_website_resources_for_select
		get_website_resources.map { |e| [e.name, e.id] }
	end
	
end
