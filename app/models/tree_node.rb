require "authentication_model"

class TreeNode < ActiveRecord::Base
  
  belongs_to :resource
  has_many :tree_node_ac_rights#, :dependent => :destroy
  acts_as_list :scope => 'parent_id = #{parent_id} AND placeholder = \'#{placeholder}\''
  acts_as_tree  :order => 'position', :counter_cache => true
  has_many :students, :dependent => :nullify
  has_many :comments, :dependent => :nullify 
  has_many :feeds, :foreign_key => :section_id

  attr_accessor :ac_type
  attr_accessor :min_permission_to_child_tree_nodes_cache

  #attribute_method_suffix '_changed?'     

  # DO NOT REMOVE !!!
  #  This is because the observer doesn't add the after_find function
  # unless you define it in your model first
  def after_find
  end

  alias :this_cache_key :cache_key

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
    @ac_type >= 3 #"Managing"
  end
  
  def can_move_child?
    @ac_type >= 3
  end
  
  def can_sort?
    @ac_type >=3
  end

  #can delete in DB (destroy)
  def can_administrate? 
    @ac_type >= 4 #"Administrating"
  end

  def main
    TreeNode.find_by_resource_id_and_is_main(resource_id, true)
  end

  def parents
    ancestors.select{ |e| e.resource.resource_type.hrid == 'content_page' }
  end

  # destroy tree_node if it is not main or mark resource as deleted if it is main
  # return true if success
  def logical_delete
    if is_main?
      resource.status = 'DELETED'
      resource.save
    else
      destroy
    end
  end
  
  # The has_url virtual variable is passed to when requesting for resource edit/create
  # if true than on the resource edit/create of this tree_node will show permalink text field
  # Embedded resources won't have permalink
  def ancestors
    TreeNode.find(:all, 
      :from => "cms_treenode_ancestors(#{self.id}, #{AuthenticationModel.current_user}) tree_nodes") rescue []
    # select * from cms_treenode_ancestors(35, 1)
  end

  class << self
    
    # This function is for cleaing URLs. It removes and replaces some charecters
    def permalink_escape(s)
      s.to_s.gsub(/\'/, '').gsub(/\&/, '').gsub(/\"/, '').gsub(/\./, '').gsub(/\,/, '').squeeze(" ").strip.gsub(/ /, "-")
    end  

    # Get tree nodes according to the parameters
    # Hash of params:
    # :parent => 10 - integer - required
    # :resource_type_hrids => ['website', 'content_page'] - array of strings - optional - default: show all
    # :is_main => true - boolean - optional - default: show all
    # :has_url => false - boolean - optional - default: show all
    # :depth => 3 - integer - optional - default: get all the subtree
    # :properties => where clause for properties on hrids:
    # field type: each hrid must contain a prefix of its field type. t_ b_ d_ n_ when  t_ is for string, text, plaintext, file(the file name); b_ is for boolean; d_ is for dates and timestamps; n_ is for numbers. For eaxmple - my hrid is num_of_items and its a number so I will use: n_num_of_items = 4; Or can_edit is boolean so I'll write: b_can_write = true OR n_num_of_items = 4
    # prefix_hrid = value [and or] hrid ~ value, i.e. '(t_name ~ ''arvut'' or in_group) and (d_date > now() or d_date < now() + 15)'
    # NOTE: keep in mind that you are writing a normal query according field type and all other rules!
    # the difference is that fieldnames are properties.hrids and values are resource_properties. - optional - default: show all
    # :current_page => 3 - integer - optional - default: paging is disabled
    # :items_per_page => 10 - integer - optional - default: 25 items per page(if current page key presents)
    # :return_parent => true - boolean - optional - default: false
    # :placeholders => ['related_items', 'main_content'] - array of strings - optional - default: show all
    # :status => ['PUBLISHED', 'DRAFT'] - array of strings - optional - default - will return only PUBLISHED. 
    #   avalilable Options: 'PUBLISHED', 'DELETED', 'DRAFT', 'ARCHIVED'
    # :limit => integer - optional - default: show all
    # :order => order string - optional - default: sort by position (exapmle: :order => "created_at DESC, name")
    # :count_children => returns also number of direct children as 'direct_child_count' field
    #           - null/false (no direct_children, default)
    #           - true (direct children)
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
      if args.has_key?(:properties) && args[:properties].is_a?(String) && !args[:properties].empty?
        req_properties = "'" + args[:properties] + "'"
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
      if args.has_key?(:status)
        req_status = 'ARRAY[' + args[:status].map{|e| "'" + e.to_s + "'"}.join(',') + ']'
      else
        req_status = 'null'
      end

      request = [
        req_parent,
        AuthenticationModel.current_user,
        req_resource_type_hrids,
        req_is_main,
        req_has_url,
        # If depth == 1 we have to call different function in PL/SQL
        # and the difference is in number of parameters.
        # If depth != 1 then count_children will be ignored
        if args[:depth]
          args[:depth] unless args[:depth] == 1
        else
          'null::integer'
        end,
        req_properties,
        req_current_page,
        req_items_per_page,
        req_return_parent,
        req_placeholders,
        req_status,
        if args[:depth] && args[:depth] == 1
          args[:count_children] || 'null::boolean'
        end
      ].compact.join(',')
      if args[:test]
        return "select * from cms_treenode_subtree(#{request})"
      end
      # find_by_sql("select get_max_user_permission(#{AuthenticationModel.current_user}, tree_nodes.id) as max_user_permission, * from cms_treenode_subtree(#{request}) tree_nodes LEFT OUTER JOIN resources ON resources.id = tree_nodes.resource_id") rescue []

      sql_params = {:from => "cms_treenode_subtree(#{request}) tree_nodes", :include => [:resource] }
      # sql_params = {:from => "cms_treenode_subtree(#{request}) tree_nodes"}
      additional_params = {}
      if args.has_key?(:limit) && args[:limit].to_i > 0
        additional_params.merge!({:limit => args[:limit].to_i})
      end
      if args.has_key?(:order) && args[:order].is_a?(String)
        additional_params.merge!({:order => args[:order]})
      end
      sql_params.merge!(additional_params)
      find(:all, sql_params) rescue []

      # find(:all, :from => "cms_treenode_subtree(#{request}) tree_nodes") rescue []
      # find(:all, :from => "cms_treenode_subtree(#{request}) tree_nodes", :include => [:resource]) rescue [] ###### Eager loading
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
      unless arg.include? "cms_treenode_subtree" or arg.include? "cms_treenode_ancestors"
        arg = arg.sub(/SELECT \* FROM "*tree_nodes"* +WHERE/, "SELECT *, get_max_user_permission(#{AuthenticationModel.current_user}, tree_nodes.id) as max_user_permission_2 FROM tree_nodes   WHERE")
      end
      
      output = super(arg)
      output.delete_if {|x| x.ac_type == 0 }
      output
    end
    
    def find(*args)
      
      if args.last.is_a?(::Hash) 
        #some cms_treenode_ methods have permissions by tham self
        if args.last[:from].nil? or (args.last[:from] and not (args.last[:from].include? "cms_treenode_subtree" or args.last[:from].include? "cms_treenode_ancestors"))
          #adding permission field
          if args.last[:select]
            args.last[:select] =  args.last[:select] + ", get_max_user_permission(" + AuthenticationModel.current_user.to_s + ", id) as max_user_permission_2 " 
          else
            args.last[:select] = "*, get_max_user_permission(" + AuthenticationModel.current_user.to_s + ", id) as max_user_permission_2"
          end
        end
      else
        args[args.length] = Hash[:select => "*, get_max_user_permission(" + AuthenticationModel.current_user.to_s + ", id) as max_user_permission_2"]
      end

      super(*args)
    end

    def find_as_admin(tree_node_id)
      res = old_find_by_sql "select get_max_user_permission(#{AuthenticationModel.current_user}, id) as max_user_permission_2, * from tree_nodes where id=#{tree_node_id}"
      if res.length == 1
        return res[0]
      end
      nil
    end
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

    chields =  TreeNode.old_find_by_sql("Select get_max_user_permission(#{AuthenticationModel.current_user}, tree_nodes.id) as max_user_permission_2, * 
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

  # The function to update positions of nodes.
  # == Returns
  # * true - success
  # * false - error: uneven length of attributes, unsuccessfull save, etc.
  #
  # == Attributes
  # * nodes - list of ids and original positions of nodes to update position
  # * positions - list of _new_ positions of the nodes in the above list
  #
  def TreeNode.update_positions(nodes, positions)
    raise "Uneven arrays: nodes (#{nodes.length} elements) and positions (#{positions.length} elements).\nPlease reload the page." if nodes.length != positions.length
    transaction {
      # Go over new positions
      positions.each_with_index { |pos, idx|
        pos = pos.to_i
        # Find its id
        id = nodes.select { |node|  node[:pos] == pos}[0][:id]
        # Find tree node
        tree_node = TreeNode.find(:first, :conditions => {:id => id})
        # It's new position is now...
        new_position = nodes[idx][:pos]
        if tree_node.position != new_position
          tree_node.position = new_position
          tree_node.save
        end
      }
    }
    true
  end
end
