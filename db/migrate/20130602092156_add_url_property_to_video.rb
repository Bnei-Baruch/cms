class AddUrlPropertyToVideo < ActiveRecord::Migration
  def self.up
    migration_login

    resource_type = ResourceType.find(:first, :conditions => {:hrid => 'video'})
    raise 'Failed to find Video resource type' unless resource_type

    rid = resource_type.id

    url_property = Property.new(:name => 'URL',
                                    :field_type => 'String',
                                    :hrid => 'source_url',
                                    :position => generate_position(rid),
                                    :resource_type_id => rid)
    raise 'Failed to create URL property' unless url_property
    url_property.save!

    url_property = Property.new(:name => 'URL text',
                                    :field_type => 'String',
                                    :hrid => 'source_text',
                                    :position => generate_position(rid),
                                    :resource_type_id => rid)
    raise 'Failed to create URL property' unless url_property
    url_property.save!

    url_property = Property.new(:name => 'Open in new window',
                                    :field_type => 'Boolean',
                                    :hrid => 'source_ext',
                                    :position => generate_position(rid),
                                    :resource_type_id => rid)
    raise 'Failed to create IS EXT property' unless url_property
    url_property.save!
  end

  def self.down
    migration_login

    resource_type = ResourceType.find(:first, :conditions => {:hrid => 'video'})
    raise 'Failed to find Video resource type' unless resource_type

    property = Property.find(:first, :conditions => {:hrid => 'source_url', :resource_type_id => resource_type.id})
    if property
      resource_properties = ResourceProperty.find(:all, :conditions => {:property_id => property.id})
      resource_properties.each { |rp| rp.delete }
      property.delete
    end
    property = Property.find(:first, :conditions => {:hrid => 'source_text', :resource_type_id => resource_type.id})
    if property
      resource_properties = ResourceProperty.find(:all, :conditions => {:property_id => property.id})
      resource_properties.each { |rp| rp.delete }
      property.delete
    end
    property = Property.find(:first, :conditions => {:hrid => 'source_ext', :resource_type_id => resource_type.id})
    if property
      resource_properties = ResourceProperty.find(:all, :conditions => {:property_id => property.id})
      resource_properties.each { |rp| rp.delete }
      property.delete
    end
  end
end
