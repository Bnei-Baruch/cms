class PropertyObserver < ActiveRecord::Observer
  def after_update(property)
    # Update cache and thumbnails upon change of geometry
    Attachment.update_thumbnails(property) unless old_geometry_string.eql?(geometry_string)
  end
end