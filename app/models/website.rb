class Website < ActiveRecord::Base
	has_and_belongs_to_many :resources	
	has_and_belongs_to_many :resource_types

	def self.associate_website(object, website_id)
    # put website from session to resource
		if website_id && (website = Website.find(website_id))
			if object.new_record? || (not object.new_record?) && ((not (websites = object.websites)) || websites && (not websites.include?(website)))
				object.websites << website
			end
		end
	end
	
end
