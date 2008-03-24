class AuthenticationModel
  attr_reader :ac_type
  def initialize(access_type = 0)
      @ac_type = access_type
  end
  
   NODE_AC_TYPES = {
    #  Displayed        stored in db
    0 => "Forbidden",
    1 => "Reading",
    2 => "Editing",
    3 => "Administrating"
  }
  
  def can_edit?
    @ac_type == 2 || @ac_type == 3
  end
  
  def can_read?
    @ac_type == 1 || @ac_type == 2 || @ac_type == 3
  end
  
  def can_delete?
    @ac_type == 3
  end
  
  def can_administrate?
    @ac_type == 3
  end
  
  def to_s
    NODE_AC_TYPES[ac_type]
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
  
  
  def self.get_ac_type_to_tree_node(tree_node_id)
    sql = ActiveRecord::Base.connection()
    if current_user.nil?
      return 0 #"Forbidden"
    end
    if current_user_is_admin?
      return 3 #"Administrating"
    end
    res = sql.execute("select get_max_user_permission(#{current_user},#{tree_node_id}) as value")
    answ = res.getvalue( 0, 0 )
    answ ||= 0
    return answ
  end
  
  def self.current_user
    $session[:user_id]
  end
  
  def self.current_user_is_admin?
    $session[:user_is_admin]==1
  end
end
