class RemoveTemplateForAttributeAbcInContentPage < ActiveRecord::Migration
  def self.up
    migration_login

    resource_type = ResourceType.find(:first, :conditions => {:hrid => 'content_page'})
    raise 'Failed to find content_page resource type' unless resource_type

    property = Property.find_by_hrid('abc_role')
    property.pattern = ''
    property.save!
    require 'pp'
    property = Property.find_by_hrid('abc_role')
    pp property
  end

  def self.down
  end
end
