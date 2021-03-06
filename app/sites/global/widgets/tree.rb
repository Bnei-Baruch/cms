class Global::Widgets::Tree < WidgetManager::Base
  
  attr_accessor :counter
  
  def initialize(*args, &block)
    super
    @website_parent_node = presenter.website_node.id
    @ancestors = presenter.parents.collect{|a|a.id} + [presenter.node.id]
    @ancestors.reject! { |id| id == @website_parent_node }
    @counter = -1
  end
  
             
  # Respond to tree node movements (Drag-drop)
  def render_tree_nodes_exchange
    target_node_id = @options[:target_node_id]
    source_node_id = @options[:source_node_id]

    return rawtext(false) if source_node_id.to_i == -1 # Dummy node

    target_node = TreeNode.find(target_node_id)
    source_node = TreeNode.find(source_node_id)

    target_node_parent = target_node.parent
    source_node_parent = source_node.parent
    unless source_node_parent.eql?(target_node_parent)
      return rawtext(false) unless source_node_parent.can_move_child? && target_node_parent.can_move_child? # Check for moving permission
    else
      return rawtext(false) unless source_node_parent.can_sort? # Check for sorting permission
    end

    case @options[:point]
    when 'above'
      source_node.remove_from_list
      source_node.parent = target_node.parent
      source_node.insert_at(target_node.position || 0)

    when 'below'
      source_node.remove_from_list
      source_node.parent = target_node.parent
      source_node.insert_at(target_node.position + 1)

    when 'append' # Source node was added to the target tree branch
      source_node.remove_from_list
      source_node.parent = target_node
      source_node.insert_at
      source_node.move_to_bottom

    end
  end
  
  def render_json_node
    id = @options[:node].to_i
    rawtext level_nodes(id, false)
  end

  def render_static
    unless presenter.main_section.nil? or (nodes = all_nodes).blank?
        ul(:class => 'static') {
        # We're going to draw only those nodes that are on path
        build_tree(true, nodes).each {|element| draw_tree element}
      }
    end
  end

  def render_static_ltr
    nodes = all_nodes(true, @website_parent_node)
    unless nodes.blank?
      ul(:id => 'static-menu') {
        build_tree(true, nodes).each {|element| draw_ltr_tree element}
      }
    end
  end

  def render_dynamic
    if tree_node.can_edit?
      user_name = User.find(AuthenticationModel.current_user).username rescue 'Current user'
      url = tree_node.parent_id == 0 ? domain : get_page_url(tree_node)
      link = _(:'administration_tree') + '&nbsp;&nbsp&nbsp;&nbsp;<a target="_blank" href='+_(:url_bug_report)+'>'+_(:bug_report)+'</a>&nbsp;&nbsp;&nbsp;&nbsp;<a href="' + url + '?logout=true">' + _(:logout_from) + ' ' + user_name + '</a>'

      @counter += 1
      label = "TREE_#{@counter}"
      name = @presenter.website.hrid.gsub(/\'/, '&#39;')
      div(:id => label, :class => 'dynamic_tree') {
        div(:style => 'float:left'){
          rawtext "Status: #{_(tree_node.resource.status.to_sym)}"
        }
        javascript {
          rawtext <<-TREE_CODE
            Ext.onReady(function(){
              create_tree({
                url:'#{get_page_url(tree_node)}',
                tree_label:'#{label}',
                title:'#{link}',
                expand_path:'#{expand_path}',
                resource_type_id:'#{ResourceType.get_resource_type_by_hrid('content_page').id}',
                root_id:'#{@website_parent_node}',
                admin_url:'#{new_admin_resource_path(:slang => @presenter.site_settings[:short_language])}',
                root_title:'#{name}',
                width:400
              });
            });
          TREE_CODE
        }
      }                     
    end
  end

  private

  def expand_path
    #    path = @ancestors.reject {|e| e.eql?(@ancestors.last)}
    "/#{@website_parent_node}/" + @ancestors.join('/')
  end
  
  # Fetch all subnodes of a specific node of website
  # used in dynamic tree
  def level_nodes(node_id, regular_user = true)
    if regular_user
      #properties =  'b_hide_on_navigation = false'
      #status = ['PUBLISHED']
      properties =  ' AND cms_cache_resource_properties.b_hide_on_navigation = TRUE'
      status = "resources.status = 'PUBLISHED'"
    else
      #properties = nil
      #status = ['PUBLISHED', 'DRAFT', 'ARCHIVED']
      properties = ''
      status = "resources.status in ('PUBLISHED', 'DRAFT', 'ARCHIVED')"
    end
    #nodes = TreeNode.get_subtree(
      #:parent => node_id,
      #:resource_type_hrids => ['content_page'],
      #:properties => properties,
      #:status => status,
      #:depth => 1,
      #:items_per_page => 1_000,
      #:count_children => true
    #)
    nodes = TreeNode.find_by_sql(<<-SQL
SELECT tree_nodes.* FROM tree_nodes
INNER JOIN resources ON (tree_nodes.resource_id = resources.id AND #{status})
INNER JOIN resource_types ON (resources.resource_type_id = resource_types.id AND resource_types.hrid  = 'content_page')
INNER JOIN cms_cache_resource_properties ON (cms_cache_resource_properties.resource_id = resources.id#{properties})
WHERE parent_id = #{node_id}
ORDER BY position
    SQL
    )
    json = nodes.collect { |node|
      # If node has no direct children, but is section - it is not leaf
      resource = node.resource
      acts_as_section = resource.properties('acts_as_section').get_value rescue false
      direct_child_count = TreeNode.find_by_sql(<<-SQL
SELECT tree_nodes.* FROM tree_nodes
INNER JOIN resources ON (tree_nodes.resource_id = resources.id AND #{status})
INNER JOIN resource_types ON (resources.resource_type_id = resource_types.id AND resource_types.hrid  = 'content_page')
INNER JOIN cms_cache_resource_properties ON (cms_cache_resource_properties.resource_id = resources.id#{properties})
WHERE parent_id = #{node.id}
      SQL
						    )
      node.direct_child_count = direct_child_count.length
      is_leaf = node.direct_child_count == 0 && !acts_as_section
      id = node.id
      klass = resource.status == 'PUBLISHED' ? '' : resource.status.downcase
      begin
        is_mobile = resource.properties('mobile_content').get_value
        klass += is_mobile ? ' mobile ' : ' '
        is_mobile_first_page = resource.properties('mobile_first_page').get_value
        klass += is_mobile_first_page ? ' mobile_first ' : ' '
      rescue
        
      end
      name = "<span class='#{klass}'>#{resource.name}</span>"
      [
        :id => id, 
        :text => name,
        :href => get_page_url(node),
        :leaf => is_leaf,
        :resource_name => resource.name,
        :parent_id => node.parent_id,
        :is_mobile => is_mobile,
        :is_mobile_first_page => is_mobile_first_page ? 1 : 0,
        :may_be_mobile_first_page => acts_as_section ? 0 : 1,
        :cannot_edit => !node.can_edit?,
        :cannot_create_child => !node.can_create_child?,
        :cannot_delete => !node.can_delete?,
        :addTarget => new_admin_resource_path(:slang => @presenter.site_settings[:short_language]),
        :delTarget => tree_node_delete_admin_tree_node_path(id),
        :updateStatus => update_state_admin_tree_node_path(id),
        :editTarget => edit_admin_resource_path(:id => resource,
          :tree_id => id,
          :slang => @presenter.site_settings[:short_language]
        )
      ]
    }
    json.empty? && json = [:id => -1, :text => 'Do not move!', :leaf => true]
    json.flatten.to_json
  end

  # Fetch all sub-nodes of website
  # Used in static tree
  def all_nodes(regular_user = true, parent = nil)
    if regular_user
      properties =  'b_hide_on_navigation = false'
      parent ||= presenter.main_section.id rescue nil
      status = ['PUBLISHED']
    else
      properties = nil
      parent ||= @website_parent_node
      status = ['PUBLISHED', 'DRAFT', 'ARCHIVED']
    end
    TreeNode.get_subtree(
      :parent => parent,
      :resource_type_hrids => ['content_page'],
      :properties => properties,
      :status => status,
      :depth => 1,
      :items_per_page => 1_000,
      :has_url => true,
      :count_children => true
    )
    
  end

  def draw_tree(node)
    item = node.shift
    children = node
    if item[:submenu]
      if item[:selected] # Display subtree
        li(:class => "submenu selected") {
          draw_link item[:item]
          ul {
            children.each {|element| draw_tree element}
          }
        }
      else #No subtree, just node itself
        li() {
          draw_link item[:item]
        }
      end
    else # 'final' element
      li(:class => "final#{item[:selected] ? ' selected' : ''}"){
        draw_link item[:item]
      }
    end
  end

  def draw_ltr_tree(node)
    # :item => tree_node
    # :class => submenu -- has subitems,
    #           final   -- has no subtree
    # :selected => true -- is on the path to a currently displayed page

    item = node.shift
    children = node
    if item[:submenu]
      if item[:selected]
        klass_link, li_link = 'minus selected', 'selected'
      else
        klass_link, li_link = 'plus', ''
      end
      li(:class => li_link){
        draw_link item[:item], klass_link
        ul {
          children.each {|element| draw_ltr_tree element}
        }
      }
    else # 'final' element
      li{
        draw_link item[:item], "#{item[:selected] ? ' selected' : ''}"
      }
    end
  end

  def draw_link(tree_node, klass = '')
    name = tree_node.resource.name
    a name, :class => klass, :title => name, :href => get_page_url(tree_node)
  end
  
  # 
  # Produces an array of hashes
  # Each element of hash is:
  # :item => tree_node
  # :class => submenu -- has subitems,
  #           final   -- has no subtree
  # :selected => true -- is on the path to a currently displayed page
  def build_tree(regular_user, nodes)
    nodes.collect { |node|
      if node.direct_child_count == 0
        # No children -- final element
        [{:item => node, :selected => @ancestors.include?(node.id)}]
      else
        # Has children -- submenu
        if @ancestors.include?(node.id)
          # On path -- to show children
          subtree = build_tree(regular_user, all_nodes(regular_user, node.id))
          [{:item => node, :submenu => true, :selected => true}] + subtree
        else
          # Not on path -- to show only the element itself
          [{:item => node, :submenu => true}]
        end
      end
    }
  end

end

# Example of a tree for Ext Tree
#[
#  {
#    "href": "http://hebrew.localhost:3000/kab/hagim-bakabbalah?",
#    "leaf": false,
#    "text": "\u05d7\u05d2\u05d9\u05dd \u05d1\u05e7\u05d1\u05dc\u05d4",
#    "id": 46,
#    "children": 
#      [{
#        "href": "http://hebrew.localhost:3000/kab/tu-bishvat?",
#        "leaf": false,
#        "text": "\u05d8\"\u05d5 \u05d1\u05e9\u05d1\u05d8",
#        "id": 47,
#        "children":
#          [{
#            "href": "http://hebrew.localhost:3000/kab/tu-bishvat-hag-hamekubalim?",
#            "leaf": true,
#            "text": "\u05d8\"\u05d5 \u05d1\u05e9\u05d1\u05d8 - \u05d7\u05d2 \u05d4\u05de\u05e7\u05d5\u05d1\u05dc\u05d9\u05dd",
#            "id": 48,
#            "parent_id": 47
#          }],
#        "parent_id": 46
#      }],
#    "parent_id": 42
#  },
#  {
#    "href": "http://hebrew.localhost:3000/kab/hagim-1?",
#    "leaf": false,
#    "text": "hagim-1",
#    "id": 54,
#    "children":
#      [
#        {
#          "href": "http://hebrew.localhost:3000/kab/hagim-11?",
#          "leaf": true,
#          "text": "hagim-11",
#          "id": 58,
#          "parent_id": 54
#        },
#        {
#          "href": "http://hebrew.localhost:3000/kab/hag12?",
#          "leaf": true,
#          "text": "hag12",
#          "id": 59,
#          "parent_id": 54
#        }
#      ],
#    "parent_id": 42
#  }
#]
#
