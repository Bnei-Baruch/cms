class ChangeDefaultValueOfPreview < ActiveRecord::Migration
  def self.up
    migration_login

    resource_type = ResourceType.find(:first, :conditions => {:hrid => 'content_preview'})
    raise 'Failed to find content_preview resource type' unless resource_type

    property = Property.find_by_hrid('show_title')
    property.default_code = 'false'
    property.save!
    require 'pp'
    property = Property.find_by_hrid('show_title')
    pp property
  end

  def self.down
  end
end
