class AddBlockHolderWidget < ActiveRecord::Migration
  def self.up
    migration_login

    resource_type = ResourceType.find(:first, :conditions => ['hrid = ?', 'block_holder'])
    if resource_type
      puts 'Block Holder exists'
      return
    end

    puts 'Going to create Block Holder'

    resource_type = ResourceType.new(:name => 'Block Holder',
                                     :name_code => '<block>',
                                     :hrid => 'block_holder')
    raise 'Failed to create block_holder' unless resource_type
    resource_type.save!
    resource_type = ResourceType.find(:first, :conditions => ['hrid = ?', 'block_holder'])

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

    block_name_property = Property.new(
        :name => 'Block Name',
        :field_type => 'String',
        :hrid => 'block',
        :resource_type_id => rid,
        :position => generate_position(rid),
        :is_required => false)
    raise 'Failed to create block_name_property' unless block_name_property
    block_name_property.save!
  end

  def self.down
    migration_login

    resource_type = ResourceType.find(:first, :conditions => {:hrid => 'block_holder'})
    return unless resource_type

    property = Property.find(:first, :conditions => {:hrid => 'title', :resource_type_id => resource_type.id})
    if property
      resource_properties = ResourceProperty.find(:all, :conditions => {:property_id => property.id})
      resource_properties.each { |rp| rp.delete }
      property.delete
    end

    property = Property.find(:first, :conditions => {:hrid => 'block', :resource_type_id => resource_type.id})
    if property
      resource_properties = ResourceProperty.find(:all, :conditions => {:property_id => property.id})
      resource_properties.each { |rp| rp.delete }
      property.delete
    end

    resource_type.delete
  end
end