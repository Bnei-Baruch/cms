class AddHeaderToContentPreview < ActiveRecord::Migration
  def self.up
    migration_login

    resource_type = ResourceType.find(:first, :conditions => {:hrid => 'content_preview'})
    raise 'Failed to find content_preview resource type' unless resource_type

    property = Property.new(
      :name => 'URL',
      :field_type => 'String',
      :hrid => 'url',
      :resource_type_id => resource_type.id,
      :is_required => false)
    raise 'Failed to create property \'URL\'' unless property
    property.save!

    property = Property.new(
      :name => 'URL string',
      :field_type => 'String',
      :hrid => 'url_string',
      :resource_type_id => resource_type.id,
      :is_required => false)
    raise 'Failed to create property \'URL string\'' unless property
    property.save!

    property = Property.new(
      :name => 'Show Title',
      :field_type => 'Boolean',
      :hrid => 'show_title',
      :resource_type_id => resource_type.id,
      :default_code => 'f',
      :is_required => false)
    raise 'Failed to create property \'Show Title\'' unless property
    property.save!
  end

  def self.down
  end
end
