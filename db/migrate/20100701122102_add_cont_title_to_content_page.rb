class AddContTitleToContentPage < ActiveRecord::Migration
  def self.up
    migration_login

    resource_type = ResourceType.find(:first, :conditions => {:hrid => 'content_page'})
    raise 'Failed to find content_page resource type' unless resource_type

    rid = resource_type.id

    property = Property.new(
      :name => 'Title of Link',
      :field_type => 'String',
      :hrid => 'link_title',
      :resource_type_id => rid,
      :position => generate_position(rid),
      :is_required => false)
    raise 'Failed to create property \'Title of Link\'' unless property
    property.save!

    update_resource_properties(rid)
  end

  def self.down
    migration_login

    resource_type = ResourceType.find(:first, :conditions => {:hrid => 'content_page'})
    return unless resource_type

    property = Property.find(:first, :conditions => {:hrid => 'link_title', :resource_type_id => resource_type.id})
    if property
      resource_properties = ResourceProperty.find(:all, :conditions => {:property_id => property.id})
      resource_properties.each{ |rp| rp.delete }
      property.delete
    end
  end
end
