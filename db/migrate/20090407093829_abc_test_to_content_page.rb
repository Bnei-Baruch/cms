class AbcTestToContentPage < ActiveRecord::Migration
  def self.up
     migration_login

    resource_type = ResourceType.find(:first, :conditions => {:hrid => 'content_page'})
    raise 'Failed to find content_page resource type' unless resource_type

    property = Property.new(
      :name => 'ABC test - UA tracker code',
      :field_type => 'String',
      :hrid => 'abc_ua_tracker',
      :resource_type_id => resource_type.id,
      :is_required => false)
    raise 'Failed to create property \'ABC test - UA tracker code\'' unless property
    property.save!

    property = Property.new(
      :name => 'ABC test - abc check code',
      :field_type => 'String',
      :hrid => 'abc_check_code',
      :resource_type_id => resource_type.id,
      :is_required => false)
    raise 'Failed to create property \'ABC test - abc check code\'' unless property
    property.save!

    property = Property.new(
      :name => 'ABC test - Page role (A,B,C)',
      :field_type => 'String',
      :hrid => 'abc_role',
      :pattern => '[ABC]',
      :resource_type_id => resource_type.id,
      :is_required => false)
    raise 'Failed to create property \'ABC test - Page role\'' unless property
    property.save!
    
  end

  def self.down
    resource_type = ResourceType.find(:first, :conditions => {:hrid => 'content_page'})
    return unless resource_type

    property = Property.find(:first, :conditions => {:hrid => 'abc_ua_tracker', :resource_type_id => resource_type.id})
    property.delete
    property = Property.find(:first, :conditions => {:hrid => 'abc_check_code', :resource_type_id => resource_type.id})
    property.delete
    property = Property.find(:first, :conditions => {:hrid => 'abc_role', :resource_type_id => resource_type.id})
    property.delete
    
  end
end
