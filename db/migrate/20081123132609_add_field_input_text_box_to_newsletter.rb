class AddFieldInputTextBoxToNewsletter < ActiveRecord::Migration
  def self.up
    migration_login
    
    resource_type = ResourceType.find(:first, :conditions => ['hrid = ?', 'newsletter'])
    unless resource_type
      puts 'Newsletter not found, sorry!'
      return
    end

    puts 'Going to update Newsletter'
    
    input_text_form_property = Property.new(:name => 'Email From',
      :field_type => 'String',
      :hrid => 'input_box_text',
      :resource_type_id => resource_type.id, 
      :position => 5,
      :is_required => false)
    raise 'Failed to create input_text_form_property ' unless input_text_form_property 
    input_text_form_property .save!
  end

  def self.down
  end
end
