class CreateRussianSite < ActiveRecord::Migration
  def self.up
    migration_login

    params = {}
    params[:resource]
    params[:resource] = {
      'status' => 'PUBLISHED',
	    'tree_node' => {
	    	'permalink' => 'russian',
        'placeholder' => '',
        'is_main' => 'true',
        'id' => '',
        'parent_id' => '0',
        'has_url' => 'true'
      },
      'my_properties' => {
        [
          {
            'property_type' => 'RpString',
            'property_id' => '31',
            'id' => '',
            'value' => 'Russian site',
            'remove' => ''
          }
        ]
      }
    }

    russian_site = TreeNode.new(
      :name => 'Description',
      :field_type => 'Text',
      :hrid => 'description',
      :resource_type_id => resource_type.id,
      :position => 1,
      :is_required => false)
    raise 'Failed to create description_property' unless description_property
    description_property.save!

    puts 'Properties creation OK'

  end

  def self.down
  end
end
