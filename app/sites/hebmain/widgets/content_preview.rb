class Hebmain::Widgets::ContentPreview < WidgetManager::Base

  def render_full
    get_content_items
    w_class('cms_actions').new(:tree_node => tree_node, :options => {:buttons => %W{ delete_button  edit_button }}).render_to(doc)
    
    # Set the updatable div
    updatable = 'up-' + @widget_id.to_s
    div(:id => updatable){
      render_preview_update
    }
    w_class('cms_actions').new(:tree_node => tree_node, :view_mode => 'tree_drop_zone', :options => {:page_url => get_page_url(presenter.node), :updatable => updatable}).render_to(self)
  end

  # This function is initiated also in Ajax request
  def render_preview_update
    get_content_items
    max_num = get_maximum_number_of_items.to_i > 0 ? get_maximum_number_of_items.to_i : 3
    if @items_size < max_num
      add_new_item
      get_content_items
    end
      div(:class => "main_preview#{@items_size}") {
        @items_size -= 1
        @items.each_with_index { |item, index|  
          klass = index == @items_size ? 'element last' : 'element'
          div(:class => klass) {
            render_content_item(item, @items_size + 1)
          }
        }
      }                  
  end
  
  
  private
  
  def add_new_item
    begin
      target_node_id = @args_hash[:options][:target_node_id]
      resource = TreeNode.find(target_node_id).resource
      add_node_link_to_resource(tree_node, resource)
    rescue Exception => e
    end
  end
  
  def get_content_items
    @items = content_items
    @items_size = @items.size
    @widget_id = tree_node.id
    @widget_name = tree_node.resource.resource_type.hrid
  end
  
  def render_content_item(tree_node, items_size)
    klass = tree_node.resource.resource_type.hrid
    return w_class(klass).new(:tree_node => tree_node, :options => {:items_size => items_size}).render_to(self)
  end

  def content_items
    TreeNode.get_subtree(
    :parent => tree_node.id, 
    :resource_type_hrids => ['content_page'], 
    :depth => 1,
    :has_url => false,
    :is_main => false,
    :status => ['PUBLISHED', 'DRAFT', 'ARCHIVED', 'DELETED']
    )               
  end

end
