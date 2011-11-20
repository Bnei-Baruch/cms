class AddStreamerWidget < ActiveRecord::Migration
  def self.up
    migration_login

    resource_type = ResourceType.find(:first, :conditions => ['hrid = ?', 'streamer'])
    if resource_type
      puts 'Streamer exists'
      return
    end

    puts 'Going to create streamer'

    resource_type = ResourceType.new(:name => 'streamer',
      :name_code => '<title>',
      :hrid => 'streamer')
    raise 'Failed to create streamer' unless resource_type
    resource_type.save!
    resource_type = ResourceType.find(:first, :conditions => ['hrid = ?', 'streamer'])
    
    #create properties

    puts 'Going to create properties'

    rid = resource_type.id
    
    title_property = Property.new(
      :name => 'Title',
      :field_type => 'String',
      :hrid => 'title',
      :resource_type_id => rid,
      :position => generate_position(rid),
      :is_required => false)
    raise 'Failed to create title_property' unless title_property
    title_property.save!

    url_property = Property.new(
      :name => 'URL',
      :field_type => 'String',
      :hrid => 'url',
      :resource_type_id => rid,
      :position => generate_position(rid),
      :is_required => false)
    raise 'Failed to create url_property' unless url_property
    title_property.save!
  end

  def self.down
    migration_login

    resource_type = ResourceType.find(:first, :conditions => {:hrid => 'streamer'})
    return unless resource_type

    property = Property.find(:first, :conditions => {:hrid => 'title', :resource_type_id => resource_type.id})
    if property
      resource_properties = ResourceProperty.find(:all, :conditions => {:property_id => property.id})
      resource_properties.each{ |rp| rp.delete }
      property.delete
    end
    property = Property.find(:first, :conditions => {:hrid => 'url', :resource_type_id => resource_type.id})
    if property
      resource_properties = ResourceProperty.find(:all, :conditions => {:property_id => property.id})
      resource_properties.each{ |rp| rp.delete }
      property.delete
    end

    resource_type.delete
  end
end
