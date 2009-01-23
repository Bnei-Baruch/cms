class CreateLanguages < ActiveRecord::Migration
  def self.up
    migration_login

    resource_type = ResourceType.find(:first, :conditions => {:hrid => 'language'})
    return if resource_type

    puts 'Language was not found'
    
    resource_type = ResourceType.new(
      :name => 'Language',
      :name_code => '<title>',
      :hrid => 'language')
    raise 'Failed to create Language' unless resource_type
    resource_type.save!

    puts 'Language was created'
    
    property = Property.new(
      :name => 'Title',
      :field_type => 'String',
      :hrid => 'title',
      :resource_type_id => resource_type.id,
      :position => 1,
      :is_required => false)
    raise 'Failed to create property \'Title\'' unless property
    property.save!

    puts 'Title was added'
    property = Property.new(
      :name => 'URL',
      :field_type => 'String',
      :hrid => 'url',
      :resource_type_id => resource_type.id,
      :position => 2,
      :is_required => false)
    raise 'Failed to create property \'URL\'' unless property
    property.save!
    puts 'URL was added'
  end

  def self.down
    resource_type = ResourceType.find(:first, :conditions => {:hrid => 'language'})
    return unless resource_type

    property = Property.find(:first, :conditions => {:hrid => 'title', :resource_type_id => resource_type.id})
    property.delete
    property = Property.find(:first, :conditions => {:hrid => 'url', :resource_type_id => resource_type.id})
    property.delete

    resource_type.delete
  end
end
