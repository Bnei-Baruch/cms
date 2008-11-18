class UpdateResourceThirdCampusForm < ActiveRecord::Migration
  def self.up
    migration_login
    
    resource_type = ResourceType.find(:first, :conditions => ['hrid = ?', 'campus_form'])
    unless resource_type
      puts 'Campus form not found, sorry!'
      return
    end
    
    puts 'Going to update Campus form'
    
    
    email_form_property = Property.find(:first, :conditions => ['hrid = ?', 'email_from'] )
    email_to_property = Property.find(:first, :conditions => ['hrid = ?', 'email_to'])
    text_email_property = Property.find(:first, :conditions => ['hrid = ?', 'text_email'] )
    text_conf_property = Property.find(:first, :conditions => ['hrid = ?', 'text_conf'] )
    do_not_send_property = Property.find(:first, :conditions => ['hrid = ?', 'do_not_send'] )
    list_name_property = Property.find(:first, :conditions => ['hrid = ?', 'list_name'] )
    description_property = Property.find(:first, :conditions => ['hrid = ?', 'description'] )
    
    description_property.update_attributes!(:name => 'Title and description')
    email_form_property.update_attributes!(:position => 3)
    email_to_property.update_attributes!(:position => 4)
    text_email_property.update_attributes!(:position => 5, :name => 'Email subject')
    text_conf_property.update_attributes!(:position => 6)
    do_not_send_property.update_attributes!(:position => 7, :name => 'Do not send confirmation letter')
    list_name_property.update_attributes!(:position => 8)
    
    
    
  end

  def self.down
  end
end
