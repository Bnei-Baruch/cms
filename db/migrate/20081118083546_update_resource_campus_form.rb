class UpdateResourceCampusForm < ActiveRecord::Migration
  def self.up
    migration_login
    
    resource_type = ResourceType.find(:first, :conditions => ['hrid = ?', 'campus_form'])
    unless resource_type
      puts 'Campus form not found, sorry!'
      return
    end

    puts 'Going to update Campus form'
    
    label_1_property = Property.new(:name => 'Campus Label 1',
      :field_type => 'String',
      :hrid => 'campus_label_1',
      :resource_type_id => resource_type.id, 
      :position => 9,
      :is_required => false)
    raise 'Failed to create label_1' unless label_1_property
    label_1_property.save!
    
    hide_label_1_property = Property.new(:name => 'Hide Campus Label 1',
      :field_type => 'Boolean',
      :hrid => 'campus_hide_label_1',
      :resource_type_id => resource_type.id, 
      :position => 10,
      :is_required => false)
    raise 'Failed to create hide_label_1' unless hide_label_1_property
    hide_label_1_property.save!
    
    label_2_property = Property.new(:name => 'Campus Label 2',
      :field_type => 'String',
      :hrid => 'campus_label_2',
      :resource_type_id => resource_type.id, 
      :position => 11,
      :is_required => false)
    raise 'Failed to create label_2' unless label_2_property
    label_2_property.save!
    
    hide_label_2_property = Property.new(:name => 'Hide Campus Label 2',
      :field_type => 'Boolean',
      :hrid => 'campus_hide_label_2',
      :resource_type_id => resource_type.id, 
      :position => 12,
      :is_required => false)
    raise 'Failed to create hide_label_2' unless hide_label_2_property
    hide_label_2_property.save!
    
    label_3_property = Property.new(:name => 'Campus Label 3',
      :field_type => 'String',
      :hrid => 'campus_label_3',
      :resource_type_id => resource_type.id, 
      :position => 13,
      :is_required => false)
    raise 'Failed to create label_3' unless label_3_property
    label_3_property.save!
    
    hide_label_3_property = Property.new(:name => 'Hide Campus Label 3',
      :field_type => 'Boolean',
      :hrid => 'campus_hide_label_3',
      :resource_type_id => resource_type.id, 
      :position => 14,
      :is_required => false)
    raise 'Failed to create hide_label_3' unless hide_label_3_property
    hide_label_3_property.save!
    
  end

  def self.down
  end
end
