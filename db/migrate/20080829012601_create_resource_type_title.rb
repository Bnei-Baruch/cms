class CreateResourceTypeTitle < ActiveRecord::Migration
  def self.up
    
    migration_login
    
    resource_type = ResourceType.find(:first, :conditions => ['hrid = ?', 'title_ex'])
    if resource_type
      puts 'Title exists'
      return
    end

    puts 'Going to create Title'
      
    resource_type = ResourceType.new(:name => 'Title',
      :name_code => '<title>',
      :hrid => 'title_ex')
    raise 'Failed to create Title' unless resource_type
    resource_type.save!
     
    puts 'Title creation OK'

    #create list
    
    puts 'Going to create List'
    
    style_list = List.new(:name => 'Title Style',
      :list_type => 'string')
    raise 'Failed to create list' unless style_list
    style_list.save!
    
    list_value = ListValue.new(:string_value => 'blue',
      :list_id => style_list.id)
    raise 'Failed to create list_value' unless list_value
    list_value.save!
    
    list_value = ListValue.new(:string_value => 'gray',
      :list_id => style_list.id)
    raise 'Failed to create list_value' unless list_value
    list_value.save!
    
    puts 'List creation OK'
     
    #create properties

    puts 'Going to create properties'
    
    title_property = Property.new(:name => 'Title',
      :field_type => 'String',
      :hrid => 'title',
      :resource_type_id => resource_type.id, 
      :position => 1,
      :is_required => false)
    raise 'Failed to create title_property' unless title_property
    title_property.save!

    url_property = Property.new(:name => 'Url',
      :field_type => 'String',
      :hrid => 'url',
      :resource_type_id => resource_type.id, 
      :position => 2,
      :is_required => false)
    raise 'Failed to create url_property' unless url_property
    url_property.save!

    url_string_property = Property.new(:name => 'Url String',
      :field_type => 'String',
      :hrid => 'url_string',
      :resource_type_id => resource_type.id, 
      :position => 3,
      :is_required => false)
    raise 'Failed to create url_string_property' unless url_string_property
    url_string_property.save!

    style_property = Property.new(:name => 'Title Style',
      :field_type => 'List',
      :hrid => 'title_style',
      :list_id => style_list.id,
      :resource_type_id => resource_type.id, 
      :position => 4,
      :is_required => false)
    raise 'Failed to create style_property' unless style_property
    style_property.save!
    
     puts 'Properties creation OK'
  end

  def self.down
  end

end
