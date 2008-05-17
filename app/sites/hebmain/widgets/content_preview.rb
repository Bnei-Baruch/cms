class Hebmain::Widgets::ContentPreview < WidgetManager::Base
  # attr_accessor :items, :items_size, :widget_id, :widget_name

  def initialize(*args, &block)
    super(*args, &block)
    @items = content_items
    # debugger
    @items_size = @items.size
    @widget_id = tree_node.id
    @widget_name = tree_node.resource.resource_type.hrid
  end

  def render_full
    w_class('cms_actions').new(:tree_node => tree_node, :options => {:buttons => %W{ delete_button  edit_button }, :position => 'bottom'}).render_to(doc)

    div {
      javascript() {
        rawtext <<-EXT_ONREADY
        Ext.onReady(function(){
          tree_drop_zone("dz-#{@widget_id}", "#{@widget_id}", "#{get_page_url(presenter.node)}", "#{@widget_name}");
          });
          EXT_ONREADY
      }
      div(:id => "dz-#{@widget_id}", :class => 'drop-zone')
      render_preview_update
    }
  end

  def render_preview_update
    # debugger
    div(:class => "main_preview#{@items_size}") {
      @items_size -= 1
      @items.each_with_index { |item, index|  
        klass = index == @items_size ? 'element last' : 'element'
        div(:class => klass) {
          render_content_item(item)
        }
      }
    }
  end

  def render_content_item(tree_node)
    klass = tree_node.resource.resource_type.hrid
    return w_class(klass).new(:tree_node => tree_node).render_to(self)
  end

  def content_items
    @content_items ||=
    TreeNode.get_subtree(
    :parent => 43,#tree_node.id, 
    :resource_type_hrids => ['content_page'], 
    :depth => 1,
    # :has_url => false,
    # :is_main => false,
    :status => ['PUBLISHED', 'DRAFT', 'ARCHIVED', 'DELETED']
    )               
  end

end
