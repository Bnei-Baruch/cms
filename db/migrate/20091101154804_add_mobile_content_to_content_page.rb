class AddMobileContentToContentPage < ActiveRecord::Migration
  def self.up
    migration_login

    resource_type = ResourceType.find(:first, :conditions => {:hrid => 'content_page'})
    raise 'Failed to find content_page resource type' unless resource_type

    property = Property.new(
    :name => 'Mobile Content',
    :field_type => 'Boolean',
    :hrid => 'mobile_content',
    :resource_type_id => resource_type.id,
    :position => 27,
    :is_required => false)
    raise 'Failed to create property \'Mobile Content\'' unless property
    property.save!

  end

  def self.down
    migration_login
    
    resource_type = ResourceType.find(:first, :conditions => {:hrid => 'content_page'})
    return unless resource_type

    property = Property.find(:first, :conditions => {:hrid => 'mobile_content', :resource_type_id => resource_type.id})
    return unless property
    resource_properties = ResourceProperty.find(:all, :conditions => {:property_id => property.id})
    resource_properties.each{ |rp| rp.delete }
    property.delete
  end
end