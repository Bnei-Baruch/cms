class Hebmain::Widgets::Tree < WidgetManager::Base
  
  attr_accessor :counter
  
  def initialize(args_hash = {})
    super
    @website_parent_node = presenter.main_section.id
    @ancestors = presenter.parents.collect{|a|a.id} + [presenter.node.id]
    @ancestors.reject! { |id| id == @website_parent_node }
    @display_hidden = (@args_hash[:display_hidden] || (@args_hash[:options]&&@args_hash[:options][:display_hidden]))
    @counter = -1
  end

  def render_json_node
    id = @options[:node].to_i
    if id == 0
      build_json_tree(@website_parent_node, all_nodes).collect {|element| draw_json_tree(element)}.flatten
    else
      level_nodes(id).flatten
    end
  end

  def render_static
    ul(:class => 'static') {
      # We're going to draw only those nodes that are on path
      build_tree(@website_parent_node, all_nodes).each {|element| draw_tree element}
    }
  end
  def render_dynamic
    @counter += 1
    div(:id => "TREE_#{@counter}") {
      javascript {
        rawtext 'Ext.BLANK_IMAGE_URL="/ext/resources/images/default/s.gif";'
        rawtext 'Ext.onReady(function(){'  # Start onReady
        
        rawtext <<-TREE_CODE
            var children = #{build_json_tree(@website_parent_node, all_nodes).collect {|element| draw_json_tree(element)}.flatten.to_json};
            // create initial root node
            // create the tree
            tree = new Ext.tree.TreePanel({
                loader: new Ext.tree.TreeLoader({
                    url:'#{get_page_url(tree_node)}',
                    requestMethod:'GET',
                    baseParams:{format:'json',
                                widget:'tree',
                                view_mode:'json_node',
                                display_hidden:'t'
                               }
                  }),
                root:new Ext.tree.AsyncTreeNode({
                  text: 'Invisible Root',
                  id:'0',
                  loaded:true,
                  leaf:false,
                  children:children
                }),
                renderTo:'TREE_#{@counter}',
                title: "קבלה לפי נושאים",
                collapseFirst: true,
                autoHeight:true,
                lines:false,
                useArrows :true,
                width:180,
                enableDD:true,
                animate:true,
                rootVisible:false
              });
            // First time all branch on path was sent, so let's expand it
            tree.expandPath("#{expand_path}");
            tree.on('contextmenu', function(node, e){
              var menu = new Ext.menu.Menu({
                items: [
                  new Ext.menu.Item({
                    text: 'New',
                    disabled: node.attributes.cannot_create_child,
                    href: node.attributes.addTarget + '?' +
                        encodeURI(
                          'resource[resource_type_id]=#{ResourceType.get_resource_type_by_hrid('content_page').id}'+
                          '&resource[tree_node][has_url]=true' +
                          '&resource[tree_node][is_main]=true' +
                          '&resource[tree_node][parent_id]=' + node.id
                        )
                  }),
                  new Ext.menu.Item({
                    text: 'Edit',
                    disabled: node.attributes.cannot_edit,
                    href: node.attributes.editTarget
                  }),
                  new Ext.menu.Item({
                    text: 'Delete',
                    disabled: node.attributes.cannot_delete,
                    handler: #{delete_node}
                  }),
                ]
              });
              menu.showAt(e.getXY());
            });
        TREE_CODE
        
        rawtext '});' # End onReady
      }
    }
  end

  private

  def delete_node
    "
    function delete_node(item){
      Ext.Msg.confirm('Tree item Deletion', 'Are you sure you want to delete ' + node.text + '?',
        function(e){
          if(e == 'yes') {
            Ext.Ajax.request({
              url: node.attributes.delTarget,
              method: 'post',
              callback: #{delete_callback},
              params: { '_method': 'delete' }
            });
          } // yes
        } // func(e)
      ); // confirm
    } // func(item)
    "
  end
  
  def delete_callback
    "
       function (options, success, responce){
            if (success) {
              Ext.Msg.alert('Tree item Deletion', 'The tree item <' + node.text + '> was successfully deleted');
              node.remove();
            } else {
              Ext.Msg.alert('Tree item Deletion', 'FAILURE!!!');
            }
          }
    "
  end
  def expand_path
    #    path = @ancestors.reject {|e| e.eql?(@ancestors.last)}
    '/0/' + @ancestors.join('/')
  end
  
  # Fetch all specific node of website
  def level_nodes(node_id)
    nodes = TreeNode.get_subtree(
      :parent => node_id,
      :resource_type_hrids => ['content_page'],
      :properties => {
        :hide_on_navigation => @display_hidden
      },
      :depth => 2
    )
    nodes.select { |element| element.parent_id == node_id }.collect { |node|
      has_children = nodes.select { |child|
        child.parent_id == node.id
      }.size == 0
      
      [:id => node.id, :text => node.resource.name, :href => get_page_url(node), :leaf => has_children]
    }
  end

  # Fetch all sub-nodes of website
  def all_nodes
    properties = @display_hidden ? {} : {:hide_on_navigation => 'f'}
    TreeNode.get_subtree(
      :parent => @website_parent_node,
      :resource_type_hrids => ['content_page'],
      :properties => properties
    )
  end

  def draw_json_tree(node)
    item = node.shift
    leaf = item[:item]
    name = leaf.resource.name
    id = leaf.id
    href = get_page_url(leaf)
    if item[:submenu]
      children = node.collect {|element| draw_json_tree element}.flatten
    else
      children = false
    end
    [
      {
        :id => id, :text => name, :href => href, :leaf => !item[:submenu],
        :parent_id => leaf.parent_id,
        :cannot_edit => !leaf.can_edit?, :cannot_create_child => !leaf.can_create_child?,
        :cannot_delete => !leaf.can_delete?,
        :addTarget => new_admin_resource_path,
        :delTarget => admin_tree_node_path(leaf),
        :editTarget => edit_admin_resource_path(:id => leaf.resource, :tree_id => leaf.id)
      }.merge(children ? {:children => children} : {} )
    ]
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

  def draw_link(tree_node)
    name = tree_node.resource.name
    a name, :title => name, :href => get_page_url(tree_node)
  end
  
  # 
  # Produces an array of hashes
  # Each element of hash is:
  # :item => tree_node
  # :class => submenu -- has subitems,
  #           final   -- has no subtree
  # :selected => true -- is on the path to a currently displayed page
  def build_tree(parent_node, nodes)
    nodes.select { |node|
      node.parent_id == parent_node
    }.collect { |item|
      s = build_tree(item.id, nodes)
      if s.length == 0
        # No children -- final element
        [{:item => item, :selected => @ancestors.include?(item.id)}]
      else
        # Has children -- submenu
        if @ancestors.include?(item.id)
          # On path -- to show children
          [{:item => item, :submenu => true, :selected => true}] + s
        else
          # Not on path -- to show only the element itself
          [{:item => item, :submenu => true}]
        end
      end
    }
  end

  def build_json_tree(parent_node, nodes)
    nodes.select { |node|
      node.parent_id == parent_node
    }.collect { |item|
      s = build_json_tree(item.id, nodes)
      if s.length == 0
        # No children -- final element
        [{:item => item}]
      else
        # Has children -- submenu
        [{:item => item, :submenu => true, :selected => true}] + s
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
