class AddHideContentOfArticle < ActiveRecord::Migration
  def self.up
    migration_login

    resource_type = ResourceType.find(:first, :conditions => {:hrid => 'article'})
    raise 'Failed to find Article resource type' unless resource_type

    rid = resource_type.id

    hide_content_property = Property.new(:name => 'הסתר תוכן',
                                    :field_type => 'Boolean',
                                    :hrid => 'hide_content',
                                    :position => 1,
                                    :resource_type_id => resource_type.id)
    raise 'Failed to create Hide Content property' unless hide_content_property
    hide_content_property.save!
  end

  def self.down
    migration_login

    resource_type = ResourceType.find(:first, :conditions => {:hrid => 'article'})
    raise 'Failed to find Article resource type' unless resource_type

    property = Property.find(:first, :conditions => {:hrid => 'hide_content', :resource_type_id => resource_type.id})
    if property
      resource_properties = ResourceProperty.find(:all, :conditions => {:property_id => property.id})
      resource_properties.each { |rp| rp.delete }
      property.delete
    end
  end
end
