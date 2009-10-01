class ResourceError < ActiveRecord::Migration
  def self.up
    resource_type = ResourceType.find(:first, :conditions => ['hrid = ?', 'errormsg'])
    if resource_type
      puts 'errormsg already exists'
      return
    end

    puts 'Going to create notfound'

    resource_type = ResourceType.new(:name => 'Errormsg',
      :name_code => '<title>',
      :hrid => 'errormsg')
    raise 'Failed to create errormsg' unless resource_type
    resource_type.save!

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
  end

  def self.down
    migration_login
    resource_type = ResourceType.find(:first, :conditions => {:hrid => 'errormsg'})
    return unless resource_type

    property = Property.find(:first, :conditions => {:hrid => 'title', :resource_type_id => resource_type.id})
    return unless property
    resource_properties = ResourceProperty.find(:all, :conditions => {:property_id => property.id})
    resource_properties.each{ |rp| rp.delete }
    property.delete
    resource_type.resources.each{ |rs|
      rs.tree_nodes.each{|tr|
        tr.tree_node_ac_rights.each{|tnac| tnac.delete}
        tr.delete
      }
      rs.delete
    }
    resource_type.delete
  end
end
