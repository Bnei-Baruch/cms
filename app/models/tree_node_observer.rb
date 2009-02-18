class TreeNodeObserver < ActiveRecord::Observer
  def after_find(tree_node)
    CacheMap.add_to_tree_nodes_list(tree_node.id)

    #if user is admin set max permission
    if AuthenticationModel.current_user_is_admin?
      tree_node.ac_type = 4 #"Administrating"
    else
      #set max access type by current user
      if tree_node.attribute_present?(:max_user_permission)
        tree_node.ac_type ||= tree_node.max_user_permission.to_i
      end
      if tree_node.attribute_present?(:max_user_permission_2)
        tree_node.ac_type ||= tree_node.max_user_permission_2.to_i
      end
      tree_node.ac_type ||= AuthenticationModel.get_ac_type_to_tree_node(tree_node.id)
    end
    if tree_node.resource_status.nil?
      tstatus = tree_node.resource.status
    else
      tstatus = tree_node.resource_status
    end

    case tstatus
    when 'DRAFT'
      tree_node.ac_type = 0 if tree_node.ac_type <= 1
    when 'DELETED'
      tree_node.ac_type = 0 if tree_node.ac_type <= 2
    end
  end

  def after_save(tree_node)
    #copy parent permission to the new tree_node
    AuthenticationModel.copy_parent_tree_node_permission(tree_node)
  end

  def before_destroy(tree_node)
    #check if has permission for destroy action
    unless tree_node.can_administrate?
      if tree_node.is_main || !tree_node.can_delete?
        logger.error("User #{AuthenticationModel.current_user} has no permission " +
            "to destroy tree_node: #{tree_node.id} resource: #{tree_node.resource_id}")
        raise "User #{AuthenticationModel.current_user} has no permission " +
          "to destroy tree_node: #{tree_node.id} resource: #{tree_node.resource_id}"
      end
    end
    tree_node.tree_node_ac_rights.destroy_all
  end

  def before_update(tree_node)
    #check if has permission for edit action
    if not tree_node.can_edit?
      logger.error("User #{AuthenticationModel.current_user} has no permission " +
          "to edit tree_node: #{tree_node.id} resource: #{tree_node.resource_id}")
      raise "User #{AuthenticationModel.current_user} has no permission " +
        "to edit tree_node: #{tree_node.id} resource: #{tree_node.resource_id}"
    end

    #check if parent changed
    #if Yes check if user has permission create child to parant tree_node
    if not AuthenticationModel.current_user_is_admin?
      orig_tree_node = TreeNode.find_as_admin(tree_node.id)
      if orig_tree_node
        #check if parent changed
        if orig_tree_node.parent_id != tree_node.parent_id
          if tree_node.parent_id && tree_node.parent_id > 0
            if not TreeNode.find_as_admin(tree_node.parent_id).can_move_child?
              logger.error("User #{AuthenticationModel.current_user} has no permission " +
                  "to move a child of tree_node: #{tree_node.parent_id}. Moving tree_node #{tree_node.id} denied.")
              raise "User #{AuthenticationModel.current_user} has no permission " +
                "to move a child of tree_node: #{tree_node.parent_id}. Moving tree_node #{tree_node.id} denied."
            end
          else
            #if parent_id is nil or 0 (it is root tree_node)
            #only Adinistrator group can create it
            logger.error("User #{AuthenticationModel.current_user} has no permission " +
                "to create root tree_node: #{tree_node.id}. Moving tree_node denied. Only Administrator can do it.")
            raise "User #{AuthenticationModel.current_user} has no permission " +
              "to create root tree_node: #{tree_node.id}. Moving tree_node denied. Only Administrator can do it."
          end
        end
      end
    end
    tree_node.max_user_permission = nil
  end

  def before_create(tree_node)
    #check if has permission for criating action
    #the parant tree_node can_create_child?
    if tree_node.parent_id && tree_node.parent_id > 0
      if not TreeNode.find_as_admin(tree_node.parent_id).can_create_child?
        logger.error("User #{AuthenticationModel.current_user} has no permission " +
            "to create a child of tree_node: #{tree_node.parent_id}")
        raise "User #{AuthenticationModel.current_user} has no permission " +
          "to create a child of tree_node: #{tree_node.parent_id}"
      end
    else
      #if parent_id is nil or 0 (it is root tree_node)
      #only Adinistrator group can create it
      if not AuthenticationModel.current_user_is_admin?
        logger.error("User #{AuthenticationModel.current_user} has no permission " +
            "for creation root tree_node, only Adminitrator can create child tree_node.")
        raise "User #{AuthenticationModel.current_user} has not permission " +
          "for creation root tree_node, only Adminitrator can create child tree_node."
      end
    end
  end

  def after_destroy(tree_node)
    #delete resource if exist
    #used for recurcive delete of tree_nodes
    tree_node.resource.destroy if tree_node.resource && tree_node.is_main == true
  end

end