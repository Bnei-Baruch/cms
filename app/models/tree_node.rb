require "authentication_model"

class TreeNode < ActiveRecord::Base
  belongs_to :resource
  has_many :tree_node_ac_rights#, :dependent => :destroy
  acts_as_list :scope => 'parent_id = #{parent_id} AND placeholder = \'#{placeholder}\''
  acts_as_tree  :order => 'position', :counter_cache => true

  attr_accessor :ac_type
  attr_accessor :min_permission_to_child_tree_nodes_cache
  
  #attribute_method_suffix '_changed?'     
  
  def permalink=(value)
    write_attribute('permalink', TreeNode.permalink_escape(value))
  end

  def can_edit?
    @ac_type >= 2
  end

  def can_create_child?
    @ac_type >= 2
  end

  def can_read?
    @ac_type != 0 #"Forbidden"
  end

  #can logical delete (change status to deleted)
  def can_delete?
    min_permission_to_child_tree_nodes_cache ||= get_min_permission_to_child_tree_nodes_by_user()
    if (3 <= min_permission_to_child_tree_nodes_cache)
      #can not delete if resource has link from other tree
      output = TreeNode.get_subtree(:parent => id)
      if output
        output.delete_if {|x| x.resource.nil? || x.resource.has_links? == false }
        return false if output.length > 0
      end
      return true
    else
      return false
    end
  end

  #can delete in DB (destroy)
  def can_administrate? 
    min_permission_to_child_tree_nodes_cache ||= get_min_permission_to_child_tree_nodes_by_user()
    if (4 <= min_permission_to_child_tree_nodes_cache)
      #can not delete if resource has link from other tree
      output = TreeNode.get_subtree(:parent => id)
      if output
        output.delete_if {|x| x.resource.nil? || x.resource.has_links? == false }
        return false if output.length > 0
      end
      return true
    end 
    return false
  end


  # The has_url virtual variable is passed to when requesting for resource edit/create
  # if true than on the resource edit/create of this tree_node will show permalink text field
  # Embedded resources won't have permalink

  def after_find
    #if user is admin set max permission
    if AuthenticationModel.current_user_is_admin?
      self.ac_type ||= 4 #"Administrating"
    end
    #set max access type by current user
    if attribute_present?(:max_user_permission)
      self.ac_type ||= self.max_user_permission.to_i
    end
    self.ac_type ||= AuthenticationModel.get_ac_type_to_tree_node(self.id)
  end 

  def after_save
    #copy parent permission to the new tree_node
    AuthenticationModel.copy_parent_tree_node_permission(self)
  end

  class << self
    
    # This function is for cleaing URLs. It removes and replaces some charecters
    def self.permalink_escape(s)
      s.to_s.gsub(/\'/, '').gsub(/\&/, '').gsub(/\"/, '').gsub(/\./, '').gsub(/\,/, '').squeeze(" ").strip.gsub(/ /, "-")
    end  

    # Get tree nodes according to the parameters
    # Hash of params:
    # :parent => 10 - integer - required
    # :resource_type_hrids => ['website', 'content_page'] - array of strings - optional - default: show all
    # :is_main => true - boolean - optional - default: show all
    # :has_url => false - boolean - optional - default: show all
    # :depth => 3 - integer - optional - default: get all the subtree
    # :properties => {:description => 'a very good article', :is_hidden => 't'} - 
    #   hash of resource properties, when the key is the hrid of the property 
    #   and the value is the value of the resource property. - optional - default: show all
    # :current_page => 3 - integer - optional - default: paging is disabled
    # :items_per_page => 10 - integer - optional - default: 25 items per page(if current page key presents)
    # :return_parent => true - boolean - optional - default: false
    # :placeholders => ['related_items', 'main_content'] - array of strings - optional - default: show all
    # 
    # Examples: 
    # get_subtree(:parent => 17, :resource_type_hrids => ['website', 'content_page'], :depth => 3, :properties => {:description => 'yes sair', :title => 'good title'}, )
    # get_subtree(:parent => 17)
    # get_subtree(:parent => 17, :depth => 1)
    # get_subtree(:parent => 17, :depth => 1, :is_main => true, :has_url => true)
    def get_subtree(args)
      req_parent = args[:parent] || nil
      unless args.is_a?(Hash) && req_parent
        return []
      end
      if args.has_key?(:resource_type_hrids)
        req_resource_type_hrids = 'ARRAY[' + args[:resource_type_hrids].map{|e| "'" + e.to_s + "'"}.join(',') + ']'
      else
        req_resource_type_hrids = 'null'
      end
      req_is_main = args.has_key?(:is_main) ? args[:is_main] : 'null'                  
      req_has_url = args.has_key?(:has_url) ? args[:has_url] : 'null'
      req_depth = args[:depth] || 'null'
      if args.has_key?(:properties) && args[:properties].is_a?(Hash) && !args[:properties].empty?
        req_properties = 'ARRAY[' + args[:properties].to_a.flatten.map{|e| "'" + e.to_s + "'"}.join(',') + ']'
      else
        req_properties = 'null'
      end
      req_current_page = args[:current_page] || 'null'
      req_items_per_page = args[:items_per_page] || 'null'
      req_return_parent = args.has_key?(:return_parent) ? args[:return_parent] : 'null'
      if args.has_key?(:placeholders)
        req_placeholders = 'ARRAY[' + args[:placeholders].map{|e| "'" + e.to_s + "'"}.join(',') + ']'
      else
        req_placeholders = 'null'
      end
      
      if req_parent
        request = [
          req_parent, 
          req_resource_type_hrids, 
          req_is_main, 
          req_has_url, 
          req_depth, 
          req_properties,
          req_current_page,
          req_items_per_page,
          req_return_parent,
          req_placeholders].join(',')
          if args[:test]
            return "select get_max_user_permission(#{AuthenticationModel.current_user}, id) as max_user_permission, * from cms_treenode_subtree(#{request})"
          end
          find_by_sql("select get_max_user_permission(#{AuthenticationModel.current_user}, id) as max_user_permission, * from cms_treenode_subtree(#{request})") rescue []
        else
          []
        end
      end
    
    # call the DB function 'cms_resource_subtree' to retrieve all the website subtree as tree_node records
    def get_website_subtree(website_tree_node_id)
      if website_tree_node_id
        get_subtree(:parent => website_tree_node_id)
      else
        nil
      end
    end
    
    # def get_subtree(parent = 0, depth = 0, resource_type = nil)
    #   if resource_type == nil
    #     find_by_sql "SELECT  a.* FROM  connectby('tree_nodes', 'id', 'parent_id', 'position',  '#{parent}', #{depth}) 
    #     AS t(id int, parent_id int, level integer, position int) 
    #     join tree_nodes a on (a.id = t.id) ORDER BY  t.position"
    #   else
    #     find_by_sql "SELECT  a.* FROM  connectby('tree_nodes', 'id', 'parent_id', 'position',  '#{parent}', #{depth}) 
    #     AS t(id int, parent_id int, level integer, position int) 
    #     join tree_nodes a on (a.id = t.id)
    #     join resources r on (a.resource_id = r.id)
    #     WHERE r.resource_type_id = #{resource_type} 
    #     ORDER BY  t.position"
    #   end
    # end 

    alias :old_find_by_sql :find_by_sql
    def find_by_sql(arg)
      output=self.old_find_by_sql(arg)
      output.delete_if {|x| x.ac_type == 0 }
      output
    end
    
    alias :old_find :find
    def find(*args)
      if args.last.is_a?(::Hash) 
        if args.last[:select]
          args.last[:select] = "get_max_user_permission(" + AuthenticationModel.current_user.to_s + ", id) as max_user_permission," + args.last[:select]
        else
          args.last[:select] = "get_max_user_permission(" + AuthenticationModel.current_user.to_s + ", id) as max_user_permission, *"
        end
      else
          args[args.length] = Hash[:select => "get_max_user_permission(" + AuthenticationModel.current_user.to_s + ", id) as max_user_permission, *"]
      end
      output=self.old_find(*args)
      
      output
    end

    def find_as_admin(tree_node_id)
      res = old_find_by_sql "select get_max_user_permission(#{AuthenticationModel.current_user}, id) as max_user_permission, * from tree_nodes where id=#{tree_node_id}"
      if res.length == 1
        return res[0]
      end
      nil
    end
  end

  def before_destroy
    #check if has permission for destroy action
    if not can_administrate?
      logger.error("User #{AuthenticationModel.current_user} has no permission " + 
      "for destroy tree_node: #{id} resource: #{resource_id}")
      raise "User #{AuthenticationModel.current_user} has not permission " + 
      "for destroy tree_node: #{id} resource: #{resource_id}"
    end
    tree_node_ac_rights.destroy_all
  end

  def before_update
    #check if has permission for edit action
    if not can_edit?
      logger.error("User #{AuthenticationModel.current_user} has no permission " + 
      "for edit tree_node: #{id} resource: #{resource_id}")
      raise "User #{AuthenticationModel.current_user} has not permission " + 
      "for edit tree_node: #{id} resource: #{resource_id}"
    end
  end

  def before_create
    #check if has permission for criating action
    #the parant tree_node can_create_child?
    if parent_id && parent_id > 0
       if not TreeNode.find_as_admin(parent_id).can_create_child?
          logger.error("User #{AuthenticationModel.current_user} has no permission " + 
          "for creation child to tree_node: #{parent_id}")
          raise "User #{AuthenticationModel.current_user} has not permission " + 
          "for creation child to tree_node: #{parent_id}"
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
  
  def after_destroy
    #delete resource if exist
    #used for recurcive delete of tree_nodes
    resource.destroy if resource && is_main == true
  end

  #return min permission to child nodes by current user (recursive)
  def get_min_permission_to_child_tree_nodes_by_user()
    if AuthenticationModel.current_user_is_admin?
      return 4 #"Administrating"
    end
    result = ac_type

    #optimization (if it already minimal value)
    if result == 0 #"Forbidden"
      return result 
    end

    chields =  TreeNode.old_find_by_sql("Select get_max_user_permission(#{AuthenticationModel.current_user}, tree_nodes.id) as max_user_permission, * 
      from tree_nodes where parent_id =#{id}")
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
    result
  end

  #ExtJS tree service methods
  def self.root_nodes
    find(:all, :conditions => ["parent_id = ?", 0], :order => "position ASC")
  end

  def self.find_children(start_id = nil)
    start_id.to_i == 0 ? root_nodes : find(start_id).children
  end

  def leaf
    if children.length == 0
      true
    else
      false
    end
  end

  def to_json_with_leaf(options = {})
    self.to_json_without_leaf(options.merge(:methods => :leaf))
  end
  alias_method_chain :to_json, :leaf

  protected

  def TreeNode.find_first_parent_of_type_website(parent_id)
    node = TreeNode.find(:first, :conditions => ["parent_id = ?", parent_id])
    while node && !node.resource.resource_type.hrid.eql?('website')
      node = node.parent 
    end
    node
  end


  #def attribute_changed?(attr)
  #      
  #end
end
