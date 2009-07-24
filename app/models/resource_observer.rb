class ResourceObserver < ActiveRecord::Observer
  def after_save(resource)
    unless resource.status == 'DELETED'
      # Find instances of RpFile, i.e. attachments
      # Create thumbnails for those which are images
      properties = resource.resource_properties || resource.get_resource_properties
      properties.select {|fld| fld.instance_of?(RpFile)}.each {|rp|
        #      next unless rp.changed? -- That doesn't work for images because we always remove it
        next if !( rp.attachment && rp.attachment.is_image?)
        Attachment.create_thumbnails_and_apply_geometry_and_cache(rp)
      }
    end
    PageMap.remove_dependent_caches_by_resource(resource)
  end

  def before_destroy(resource)
    #check if can destroy by permission system 
    main_tree_node = resource.tree_nodes.main
    if main_tree_node 
      #If destroy command come as result destroy main tree_node
      #we should destroy without check permission (on that step).
      #Permissions was checked in main_tree_node destroy step.
      #We know tha.tree_nodes.main.t it come from main_tree_node destroy if it is nil
      if not main_tree_node.can_administrate? #check permission
        logger.error("User #{AuthenticationModel.current_user} has not permission " + 
            "for destroy tree_node: #{main_tree_node.id} resource: #{resource.id}")
        raise "User #{AuthenticationModel.current_user} has not permission " + 
          "for destroy tree_node: #{main_tree_node.id} resource: #{resource.id}"
        return
      end
    end
    # Clear cache and thumbnails upon deletion of RpFile
    resource.resource_properties.select {|fld| fld.instance_of?(RpFile)}.each {|rp|
      Attachment.remove_thumbnails_and_cache(rp)
    }
    PageMap.remove_dependent_caches_by_resource(resource)
  end
end
