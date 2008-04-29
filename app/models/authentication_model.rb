class AuthenticationModel
  #attr_reader :ac_type
  #attr_reader :tree_node
  #def initialize(access_type = 0)#, tree_node = nil)
  #    @ac_type = access_type
      #@tree_node = tree_node
  #end
  #include UserInfo
  
   NODE_AC_TYPES = {
    #  Displayed        stored in db
    0 => "Forbidden",
    1 => "Reading",
    2 => "Editing",
    3 => "Managing",
    4 => "Administrating"
  }
  def self.GET_NODE_AC_TYPES_FOR_EDIT
    NODE_AC_TYPES.reject {| key, value | key == 4 }
  end
  
 # def to_s
 #   NODE_AC_TYPES[ac_type]
 # end
  
  #return min permission to child nodes by current user (recursive) 999 = no child
  def self.get_min_permission_to_child_tree_nodes_by_user(tree_node_id)
    if AuthenticationModel.current_user_is_admin?
      return 4 #"Administrating"
    end
    result =999 #no child
    chields =  TreeNode.old_find_by_sql("Select * from tree_nodes 
        where parent_id =#{tree_node_id}")
    chields.each{ |tn|
        #get current node permission
        if tn.ac_type < result
          result = tn.ac_type
        end
        
        #optimization (if it already minimal value)
        if result == 0 #"Forbidden"
          return result 
        end
        #get child permission
        tmp_res = tn.get_min_permission_to_child_tree_nodes_by_user()
        if tmp_res < result
          result = tmp_res
        end
    }
    result #999 no child
  end
  
  def self.copy_parent_tree_node_permission(tree_node)
    parent_rights = TreeNodeAcRight.find(:all, 
      :conditions => ["tree_node_id = ?", tree_node.parent_id])
    action_flg = false
    #delete automatic node by parent
    tnrs = TreeNodeAcRight.find(:all, 
          :conditions => ["tree_node_id = ? and group_id not in 
          (select group_id from tree_node_ac_rights where tree_node_id = ?) 
          and is_automatic = true", 
            tree_node.id, tree_node.parent_id])
    tnrs.each{|d_tnr| 
      d_tnr.destroy
      action_flg = true
    }
    
    #add or update permission by parent node
    parent_rights.each{ |p_tnr|
      tnr = TreeNodeAcRight.find(:first, 
          :conditions => ["tree_node_id = ? and group_id = ?", 
            tree_node.id, p_tnr.group_id])
        
      if tnr.nil?
        TreeNodeAcRight.create(:tree_node_id => tree_node.id, 
          :group_id => p_tnr.group_id,
          :is_automatic => true, 
          :ac_type => p_tnr.ac_type)
        action_flg = true
      else
        if tnr.ac_type != p_tnr.ac_type && tnr.is_automatic == true
          #tnr.ac_type = p_tnr.ac_type
          TreeNodeAcRight.update(tnr.id, :ac_type => p_tnr.ac_type)
          action_flg = true
        end
      end
    }
    return action_flg
  end
  
  #recursive copy permission to child
  def self.copy_tree_node_permission_to_child(tree_node_right)
    chields =  TreeNode.old_find_by_sql("Select * from tree_nodes 
        where parent_id =#{tree_node_right.tree_node_id}")
    chields.each{ |tn|
     tnr = TreeNodeAcRight.find(:first, 
          :conditions => ["tree_node_id = ? and group_id = ?",
            tn.id, tree_node_right.group_id])
     if tnr.nil?
         tnr = TreeNodeAcRight.create(:tree_node_id => tn.id, 
              :group_id => tree_node_right.group_id,
              :is_automatic => true, 
              :ac_type => tree_node_right.ac_type)
         
     else
       #change access type by parant tree_node only if it automatic (not manual)
       if tnr.is_automatic == true &&  tnr.ac_type != tree_node_right.ac_type
         tnr.ac_type = tree_node_right.ac_type
         tnr.save
       end
     end
    }
   
  end
  
  #recursive delete permission to child
  def self.delete_tree_node_permission_to_child(tree_node_right)
    chields =  TreeNode.old_find_by_sql("Select * from tree_nodes 
        where parent_id =#{tree_node_right.tree_node_id}")
    chields.each{ |tn|
     tnr = TreeNodeAcRight.find(:first, 
          :conditions => ["tree_node_id = ? and group_id = ?",
            tn.id, tree_node_right.group_id])
     if not tnr.nil?
      
       #delete tree_node_rights only if it automatic (not manual)
       if tnr.is_automatic == true 
         tnr.destroy
       end
     end
    }
   
  end
  
  #return max permission for current user to tree_node
  def self.get_ac_type_to_tree_node(tree_node_id)
    sql = ActiveRecord::Base.connection()
    if current_user.nil?
      return 0 #"Forbidden"
    end
    if current_user_is_admin?
      return 4 #"Administrating"
    end
    res = sql.execute("select get_max_user_permission(#{current_user},#{tree_node_id}) as value")
    answ = res.getvalue( 0, 0 )
    answ ||= 0
    return answ.to_i
  end
  
  def self.current_user
    # UserInfo.current_user
   # current_user
    $session[:user_id]
  end
  
  def self.current_user_is_admin?
    #UserInfo.user_is_admin==1
    $session[:user_is_admin]==1
    #user_is_admin==1
  end

end
