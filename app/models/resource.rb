class Resource < ActiveRecord::Base
	belongs_to :resource_type
	has_many :resource_properties, :dependent => :destroy
end
