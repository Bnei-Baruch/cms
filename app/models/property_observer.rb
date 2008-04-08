class PropertyObserver < ActiveRecord::Observer
  def after_update(property)
    if property.respond_to?(:geometry_string) && property.respond_to?(:old_geometry_string)
      # Update cache and thumbnails upon change of geometry
      Attachment.update_thumbnails(property) unless old_geometry_string.eql?(geometry_string)
    end
  end
  
  def before_save(property)
    if not property.resource.main.can_edit?
       logger.error("User #{AuthenticationModel.current_user} has not permission " + 
      "for edit tree_node: #{property.resource.main.id} resource: #{property.resource_id}")
      raise "User #{AuthenticationModel.current_user} has not permission " + 
      "for edit tree_node: #{property.resource.main.id} resource: #{property.resource_id}"
      return
    end
  end
end