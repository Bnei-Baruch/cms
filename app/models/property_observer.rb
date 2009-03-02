class PropertyObserver < ActiveRecord::Observer
  def after_update(property)
    if property.changed? && property.respond_to?(:geometry_string) && property.respond_to?(:old_geometry_string)
      # Update cache and thumbnails upon change of geometry
      Attachment.update_thumbnails(property) unless old_geometry_string.eql?(geometry_string)
    end
  end
end