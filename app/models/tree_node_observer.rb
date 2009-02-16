class TreeNodeObserver < ActiveRecord::Observer
  def after_find(tree_node)
    TreeNode.tree_nodes_list << tree_node.id if TreeNode.tree_nodes_list

    #if user is admin set max permission
    if AuthenticationModel.current_user_is_admin?
      tree_node.ac_type = 4 #"Administrating"
    else
      #set max access type by current user
      if attribute_present?(:max_user_permission)
        tree_node.ac_type ||= tree_node.max_user_permission.to_i
      end
      if attribute_present?(:max_user_permission_2)
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

end