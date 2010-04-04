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
  
  # Used to login cron managers and delayed jobs
  def self.cron_manager_user_login
    username = $config_manager.appl_settings[:cron_manager_login_user][:username]
    return if (current_user && current_user == 7)
    msession = Hash.new
    password = $config_manager.appl_settings[:cron_manager_login_user][:password]
    user = User.authenticate(username, password)
    if user
      msession[:user_id] = user.id
      msession[:current_user_is_admin] = user.groups.find(:all, :conditions => {:groupname=>'Administrators'}).length
    else
      logger.error("Rss Reader user is not defined or banned. Access denied.")
      raise "Access denied for Rss Reader user."
    end

    Thread.current[:session] = msession
  end

  def self.get_anonymous_user
    {:username => $config_manager.appl_settings[:anonymous_login_user][:username],
      :password => $config_manager.appl_settings[:anonymous_login_user][:password]} rescue {}
  end
  
  #return min permission to child nodes by current user (recursive) 999 = no child
  def self.get_min_permission_to_child_tree_nodes_by_user(tree_node_id)
    if AuthenticationModel.current_user_is_admin?
      return 4 #"Administrating"
    end
    result = 999 #no child
    children =  TreeNode.old_find_by_sql("Select * from tree_nodes where parent_id =#{tree_node_id}")
    children.each { |tn|
      #get current node permission
      result = tn.ac_type if tn.ac_type < result
        
      #optimization (if it already minimal value)
      return result if result == 0 #"Forbidden"

      #get child permission
      tmp_res = tn.get_min_permission_to_child_tree_nodes_by_user()
      result = tmp_res if tmp_res < result
    }
    result #999 no child
  end
  
  #return max permission to child nodes by current user (NON-recursive)
  def self.get_max_permission_to_child_tree_nodes_by_user_one_level(tree_node_id)
    return 0 if current_user.nil? #"Forbidden"
    return 4 if current_user_is_admin? #"Administrating"
    children = TreeNode.old_find_by_sql("Select * from tree_nodes where parent_id =#{tree_node_id}")
    result = 0
    children.each { |tn|
      #get current node permission
      result = tn.ac_type if tn.ac_type > result
    }
    result
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
    if current_user.nil?
      return 0 #"Forbidden"
    end
    if current_user_is_admin?
      return 4 #"Administrating"
    end
    sql = ActiveRecord::Base.connection()
    res = sql.execute("select get_max_user_permission(#{current_user},#{tree_node_id}) as value")
    answ = res.getvalue( 0, 0 )
    answ ||= 0
    return answ.to_i
  end
  
  def self.current_user
    Thread.current[:session][:user_id] rescue nil
  end
  
  def self.current_user_is_admin?
    Thread.current[:session][:current_user_is_admin] == 1
  end
  
  def self.current_user_is_anonymous?
    Thread.current[:session][:current_user_is_anonymous] == 1
  end

  def self.logout_from_admin
    anonymous = AuthenticationModel.get_anonymous_user
    user = User.authenticate(anonymous[:username], anonymous[:password])
    if user
      Thread.current[:session][:user_id] = user.id
      Thread.current[:session][:current_user_is_admin] = 0
      Thread.current[:session][:current_user_is_anonymous] = 1
    else
      logger.error("Anonymous user is not defined or banned. Access denied.")
      raise "Access denied for anonymous user."
    end
  end
end
