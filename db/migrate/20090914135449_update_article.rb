class UpdateArticle < ActiveRecord::Migration
  def self.up
    migration_login

    resource_type = ResourceType.find(:first, :conditions => {:hrid => 'article'})
    raise 'Failed to find article resource type' unless resource_type

    property = Property.new(
      :name => 'Keywords',
      :field_type => 'String',
      :hrid => 'keywords',
      :resource_type_id => resource_type.id,
      :is_required => false)
    raise 'Failed to create property \'Keywords \'' unless property
    property.save!

  end

  def self.down
  end
end
