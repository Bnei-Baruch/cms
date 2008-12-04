class ModifyLabeloffieldInputTextBoxToNewsletter < ActiveRecord::Migration
  def self.up
    migration_login
    
    resource_type = ResourceType.find(:first, :conditions => ['hrid = ?', 'newsletter'])
    unless resource_type
      puts 'Newsletter not found, sorry!'
      return
    end

    puts 'Going to update Newsletter'
    
    input_text_form_property = Property.find(:first, :conditions => ['hrid = ?','input_box_text'])
    input_text_form_property.update_attributes!(:name => 'Input box Text')
    
  end

  def self.down
  end
end
