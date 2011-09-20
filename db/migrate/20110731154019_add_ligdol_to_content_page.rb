class AddLigdolToContentPage < ActiveRecord::Migration
  def self.up
    migration_login

    resource_type = ResourceType.find(:first, :conditions => {:hrid => 'content_page'})
    raise 'Failed to find Content Page resource type' unless resource_type

    rid = resource_type.id

    property = Property.new(
      :name => 'Image for Header',
      :field_type => 'File',
      :hrid => 'header_image',
      :resource_type_id => rid,
      :position => generate_position(rid),
      :is_required => false)
    raise 'Failed to create property \'Content Page key\'' unless property
    property.save!

    property = Property.new(
      :name => 'Image for Header (alt)',
      :field_type => 'String',
      :hrid => 'header_image_alt',
      :resource_type_id => rid,
      :position => generate_position(rid),
      :is_required => false)
    raise 'Failed to create property \'Content Page key\'' unless property
    property.save!

    property = Property.new(
      :name => 'Tab Color',
      :field_type => 'String',
      :hrid => 'tab_color',
      :resource_type_id => rid,
      :position => generate_position(rid),
      :is_required => false)
    raise 'Failed to create property \'Tab Color key\'' unless property
    property.save!
  end

  def self.down
  end
end
