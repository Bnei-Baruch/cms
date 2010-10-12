class MoreFieldsForCountdown < ActiveRecord::Migration
  def self.up
    migration_login

    resource_type = ResourceType.find(:first, :conditions => {:hrid => 'content_page'})
    raise 'Failed to find Content Page resource type' unless resource_type

    rid = resource_type.id

    property = Property.find(:first, :conditions => {:hrid => 'countdown', :resource_type_id => resource_type.id})
    if property
      resource_properties = ResourceProperty.find(:all, :conditions => {:property_id => property.id})
      resource_properties.each{ |rp| rp.delete }
      property.delete
    end

    property = Property.new(
      :name => 'Countdown',
      :field_type => 'Date',
      :hrid => 'countdown_date',
      :resource_type_id => rid,
      :position => generate_position(rid),
      :is_required => false)
    raise 'Failed to create property \'Countdown\'' unless property
    property.save!

    property = Property.new(
      :name => 'Countdown-prefix',
      :field_type => 'String',
      :hrid => 'countdown_prefix',
      :resource_type_id => rid,
      :position => generate_position(rid),
      :is_required => false)
    raise 'Failed to create property \'Countdown-prefix\'' unless property
    property.save!
    property = Property.new(
      :name => 'Countdown-suffix',
      :field_type => 'String',
      :hrid => 'countdown_suffix',
      :resource_type_id => rid,
      :position => generate_position(rid),
      :is_required => false)
    raise 'Failed to create property \'Countdown-suffix\'' unless property
    property.save!
  end

  def self.down
    migration_login

    resource_type = ResourceType.find(:first, :conditions => {:hrid => 'content_page'})
    return unless resource_type

    property = Property.find(:first, :conditions => {:hrid => 'countdown-prefix', :resource_type_id => resource_type.id})
    if property
      resource_properties = ResourceProperty.find(:all, :conditions => {:property_id => property.id})
      resource_properties.each{ |rp| rp.delete }
      property.delete
    end
    property = Property.find(:first, :conditions => {:hrid => 'countdown-suffix', :resource_type_id => resource_type.id})
    if property
      resource_properties = ResourceProperty.find(:all, :conditions => {:property_id => property.id})
      resource_properties.each{ |rp| rp.delete }
      property.delete
    end
  end
end
