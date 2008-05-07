class Hebmain::Widgets::Tree < WidgetManager::Base
  
  def initialize(args_hash = {})
    super
    @website_parent_node = presenter.main_section.id
    @ancestors = presenter.node.ancestors.collect{|a|a.id} + [presenter.node.id]
    @ancestors.reject! { |id| id == @website_parent_node }
    @display_hidden = args_hash[:display_hidden] ? 't' : 'f'
  end

  def render

    # We're going to draw only those nodes that are on path
    ul {
      build_tree(@website_parent_node, nodes).each {|element| draw_tree element}
    }
  end

  private
  
  # Fetch all sub-nodes of website
  def nodes
    TreeNode.get_subtree(
      :parent => @website_parent_node,
      :resource_type_hrids => ['content_page'],
      :properties => {
        :hide_on_navigation => @display_hidden
      }

      # DOESN'T WORK :return_parent => false
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
          a item[:item].resource.name, :title => item[:item].resource.name, :href => get_page_url(item[:item])
        }
      end
    else # 'final' element
      li(:class => "final#{item[:selected] ? ' selected' : ''}"){
        a item[:item].resource.name, :title => item[:item].resource.name, :href => get_page_url(item[:item])      }
    end
    
  end

  def draw_link tree_node
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

end