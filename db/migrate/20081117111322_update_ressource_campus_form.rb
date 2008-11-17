class UpdateRessourceCampusForm < ActiveRecord::Migration
  def self.up
    migration_login
    
    resource_type = ResourceType.find(:first, :conditions => ['hrid = ?', 'campus_form'])
    unless resource_type
      puts 'Campus form not found, sorry!'
      return
    end

    puts 'Going to update Campus form'
    
    email_from_property = Property.new(:name => 'Email From',
      :field_type => 'String',
      :hrid => 'email_from',
      :resource_type_id => resource_type.id, 
      :position => 1,
      :is_required => false)
    raise 'Failed to create email_from' unless email_from_property
    email_from_property.save!

    email_to_property = Property.new(:name => 'Email To',
      :field_type => 'String',
      :hrid => 'email_to',
      :resource_type_id => resource_type.id, 
      :position => 2,
      :is_required => false)
    raise 'Failed to create email_to' unless email_to_property
    email_to_property.save!
    
    text_email_property = Property.new(:name => 'Text Email',
      :field_type => 'String',
      :hrid => 'text_email',
      :resource_type_id => resource_type.id, 
      :position => 3,
      :is_required => false)
    raise 'Failed to create text_email' unless text_email_property
    text_email_property.save!
    
    text_conf_property = Property.new(:name => 'Text Conf',
      :field_type => 'text',
      :hrid => 'text_conf',
      :resource_type_id => resource_type.id, 
      :position => 4,
      :is_required => false)
    raise 'Failed to create text_conf' unless text_conf_property
    text_conf_property.save!
    
    do_not_send_property = Property.new(:name => 'Do Not Send',
      :field_type => 'boolean',
      :hrid => 'do_not_send',
      :resource_type_id => resource_type.id, 
      :position => 5,
      :is_required => false)
    raise 'Failed to create do_not_send' unless do_not_send_property
    do_not_send_property.save!
    
    list_name_property = Property.new(:name => 'List Name',
      :field_type => 'String',
      :hrid => 'list_name',
      :resource_type_id => resource_type.id, 
      :position => 6,
      :is_required => false)
    raise 'Failed to create list_name' unless list_name_property
    list_name_property.save!
    

    
    
  end

  def self.down
  end
end
