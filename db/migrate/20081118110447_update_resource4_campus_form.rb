class UpdateResource4CampusForm < ActiveRecord::Migration
  def self.up
    migration_login
    
    resource_type = ResourceType.find(:first, :conditions => ['hrid = ?', 'campus_form'])
    unless resource_type
      puts 'Campus form not found, sorry!'
      return
    end
    
    puts 'Going to update Campus form'
    
    label_1_property = Property.find(:first, :conditions => ['hrid = ?', 'campus_label_1'] )
    label_1_property.update_attributes!(:position => 9)
    label_2_property = Property.find(:first, :conditions => ['hrid = ?', 'campus_label_2'] )
    label_2_property.update_attributes!(:position => 12)
    label_3_property = Property.find(:first, :conditions => ['hrid = ?', 'campus_label_3'] )
    label_3_property.update_attributes!(:position => 15)
    
    hide_label_1_property = Property.find(:first, :conditions => ['hrid = ?', 'campus_hide_label_1'])
    hide_label_1_property.update_attributes!(:position => 10)
    hide_label_2_property = Property.find(:first, :conditions => ['hrid = ?', 'campus_hide_label_2'])
    hide_label_2_property.update_attributes!(:position => 13)
    hide_label_3_property = Property.find(:first, :conditions => ['hrid = ?', 'campus_hide_label_3'])
    hide_label_3_property.update_attributes!(:position => 16)
    
    puts 'Going to create some new fields in Campus form'
    
    is_mandatory_label_1_property = Property.new(:name => 'Campus Label 1 mandatory',
      :field_type => 'Boolean',
      :hrid => 'campus_label_1_is_mandatory',
      :resource_type_id => resource_type.id, 
      :position => 11,
      :is_required => false)
    raise 'Failed to create campus_label_1_is_mandatory' unless is_mandatory_label_1_property 
    is_mandatory_label_1_property .save!
    
    is_mandatory_label_2_property = Property.new(:name => 'Campus Label 2 mandatory',
      :field_type => 'Boolean',
      :hrid => 'campus_label_2_is_mandatory',
      :resource_type_id => resource_type.id, 
      :position => 14,
      :is_required => false)
    raise 'Failed to create campus_label_2_is_mandatory' unless is_mandatory_label_2_property 
    is_mandatory_label_2_property .save!
    
    is_mandatory_label_3_property = Property.new(:name => 'Campus Label 3 mandatory',
      :field_type => 'Boolean',
      :hrid => 'campus_label_3_is_mandatory',
      :resource_type_id => resource_type.id, 
      :position => 17,
      :is_required => false)
    raise 'Failed to create campus_label_3_is_mandatory' unless is_mandatory_label_3_property 
    is_mandatory_label_3_property .save!
    
  end

  def self.down
  end
end
