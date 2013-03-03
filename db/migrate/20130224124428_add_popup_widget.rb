class AddPopupWidget < ActiveRecord::Migration
  PROPERTIES = [
      {:name => 'button-text', :field_type => 'String', :hrid => 'button_text'},
      {:name => 'title', :field_type => 'String', :hrid => 'title'},
      {:name => 'text-on-page', :field_type => 'Text', :hrid => 'text_on_page'},
      {:name => 'subscriber_name', :field_type => 'String', :hrid => 'subscriber_name'},
      {:name => 'email', :field_type => 'String', :hrid => 'email'},
      {:name => 'ymlp', :field_type => 'String', :hrid => 'ymlp'},
      {:name => 'confirm-required', :field_type => 'Boolean', :hrid => 'confirm_required'},
      {:name => 'confirm-text', :field_type => 'String', :hrid => 'confirm_text'},
      {:name => 'list-required', :field_type => 'Boolean', :hrid => 'list_required'},
      {:name => 'list-default-option', :field_type => 'String', :hrid => 'list_default_option'},
      {:name => 'free-text-required', :field_type => 'Boolean', :hrid => 'free_text_required'},
      {:name => 'free-text', :field_type => 'String', :hrid => 'free_text'},
      {:name => 'submit-text', :field_type => 'String', :hrid => 'submit_text'},
      {:name => 'direct-link-text', :field_type => 'String', :hrid => 'direct_link_text'},
      {:name => 'direct-link-url', :field_type => 'String', :hrid => 'direct_link_url'},
  ]

  def self.up
    migration_login

    widget_name = 'popup'
    resource_type = ResourceType.find(:first, :conditions => ['hrid = ?', widget_name])
    if resource_type
      say "Widget #{widget_name} exists"
      return
    end

    say "Going to create widget #{widget_name}"
    resource_type = ResourceType.new(:name => widget_name,
                                     :name_code => '<title>',
                                     :hrid => widget_name)
    raise "Failed to create widget #{widget_name}" unless resource_type
    resource_type.save!
    resource_type = ResourceType.find(:first, :conditions => ['hrid = ?', widget_name])

    say 'Going to create properties'

    rid = resource_type.id

    PROPERTIES.each { |property_data|
      data = property_data.merge(:resource_type_id => rid,
                                 :position => generate_position(rid),
                                 :is_required => false
      )
      property = Property.new(data)
      say "Property created: #{property_data[:name]}", true if property
      raise "Property failed: #{property_data[:name]}" unless property
      property.save!
    }
  end

  def self.down
    migration_login

    resource_type = ResourceType.find(:first, :conditions => {:hrid => 'popup'})
    return unless resource_type

    PROPERTIES.each {|property_data|
      property = Property.find(:first, :conditions => {:hrid => property_data[:hrid], :resource_type_id => resource_type.id})
      if property
        resource_properties = ResourceProperty.find(:all, :conditions => {:property_id => property.id})
        resource_properties.each { |rp| rp.delete }
        property.delete
      end
    }

    resource_type.delete
  end
end