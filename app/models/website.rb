class Website < ActiveRecord::Base
	has_and_belongs_to_many :resources	
	has_and_belongs_to_many :resource_types

  validates_presence_of :name
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
    url = (domain + "/" + prefix).gsub(/[^:]\/\//, '/')
    if (url).blank?
			errors.add(:domain_and_prefix, ActiveRecord::Errors.default_error_messages[:empty])
			return
    end

    # validates_format_of url, //
    unless url =~ /(http|https):\/\/[\w\-_]+(\.[\w\-_]+)?([\w\-\.,@?^=%&amp;:\/~\+#]*[\w\-\@?^=%&amp;\/~\+#])?/
      errors.add(:domain_and_prefix, ActiveRecord::Errors.default_error_messages[:invalid])
			return
    end

    # validates_uniqueness_of url
    unless Website.find(:all, :conditions => ['domain = ? AND prefix = ?', domain, prefix]).empty?
			errors.add(:domain_and_prefix, ActiveRecord::Errors.default_error_messages[:taken])
		end
  end
end
