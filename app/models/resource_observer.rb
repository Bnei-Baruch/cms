class ResourceObserver < ActiveRecord::Observer
  def after_save(resource)
    # Find instances of RpFile, i.e. attachments
    # Create thumbnails for those which are images
    resource.resource_properties.select {|fld| fld.instance_of?(RpFile)}.each {|rp|
      next unless rp.attachment && rp.attachment.is_image?
      Attachment.create_thumbnails_and_apply_geometry_and_cache(rp)
    }
  end

  def before_destroy(resource)
    # Clear cache and thumbnails upon deletion of RpFile
    resource.resource_properties.select {|fld| fld.instance_of?(RpFile)}.each {|rp|
      Attachment.remove_thumbnails_and_cache(rp)
    }
  end
end
