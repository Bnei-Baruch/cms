class CrossPageLink < ActiveRecord::Migration
  def self.up
    migration_login

    resource_type = ResourceType.find(:first, :conditions => ['hrid = ?', 'cross_page_link'])
    if resource_type
      puts 'Cross page link resource already exists'
      return
    end

    puts 'Going to create Cross page link '

    resource_type = ResourceType.new(:name => 'CrossPageLink',
      :name_code => '<cross_page_link>',
      :hrid => 'cross_page_link')
    raise 'Failed to create Cross page link' unless resource_type
    resource_type.save!

    puts 'Cross page link creation OK'

    #create properties

    puts 'Going to create properties'

    title_property = Property.new(:name => 'Title',
      :field_type => 'String',
      :hrid => 'title',
      :resource_type_id => resource_type.id,
      :position => 1,
      :is_required => false)
    raise 'Failed to create URL_property' unless title_property
    title_property.save!

    link_property  = Property.new(:name => 'Link',
      :field_type => 'String',
      :hrid => 'link',
      :resource_type_id => resource_type.id,
      :position => 4,
      :is_required => false)
    raise 'Failed to create link_property' unless link_property
    link_property.save!

    puts 'Properties creation OK'
  end

  def self.down
  end
end
