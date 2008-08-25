class Hebmain::Widgets::ContentPreview < WidgetManager::Base

  attr_accessor :updatable
  
  def render_full
    get_content_items
    div(:class => 'content_preview'){
      buttons = %W{edit_button delete_button}
      if @items_size < @max_num
        buttons = %W{new_button} + buttons
      end
      
      # Set the updatable div  - THIS DIV MUST BE AROUND THE CONTENT TO BE UPDATED.
      @updatable = 'up-' + tree_node.id.to_s
      div(:id => @updatable){
        w_class('cms_actions').new(:tree_node => tree_node, 
          :options => {:buttons => buttons,
            :button_text => 'ניהול תצוגה מקדימה', 
            :new_text => 'הוספת יחידה בצורה ידנית', 
            :has_url => false,
            :resource_types => %W{ custom_preview }}).render_to(self)
        
        render_preview_update(true)
      }
      if !@is_main_format
        w_class('cms_actions').new(:tree_node => tree_node, :view_mode => 'tree_drop_zone', :options => {:page_url => get_page_url(presenter.node), :updatable => updatable, :updatable_view_mode => 'preview_update'}).render_to(self)
      end
    }
  end

  # This function is initiated also in Ajax request
  def render_preview_update(show = false)
    @updatable ||= 'up-' + tree_node.id.to_s
    
    get_content_items
        
    is_rebuild = false
    if tree_node.resource.resource_type.hrid != 'custom_preview' && @items_size >= @max_num && !show
      is_rebuild = true
    end
    
    if is_rebuild
      if @items.last.is_main && @items.last.can_delete?
        @items.last.max_user_permission = nil
        @items.last.destroy
      else
        remove_link_from_resource(@items.last) 
      end
    end

    if @items_size < @max_num || is_rebuild
      add_new_item
      get_content_items
    end

    if !show
      @items.last.move_to_top
      get_content_items
    end

    sort_direction = if @is_main_format
      show_main_format
    else
      if is_articles_index?
        show_index
      else
        show_preview
      end
    end
    make_sortable(:selector => "##{updatable} .sortable", :direction => sort_direction) {
      content_items(tree_node.id)
    }
  end

  private

  def show_main_format
    case @items_size
    when 1
      view_mode = 'large_main_format'
    when 2
      view_mode = 'medium_main_format'
    when 3
      view_mode = 'small_main_format'
    end
    div(:class => "main_preview#{@items_size} sortable") {
      @items.each_with_index { |item, index|  
        klass = (index + 1) == @items_size ? 'element last' : 'element'
        div(:class => klass, :id => sort_id(item)) {
          sort_handle
          show_item(item, view_mode)
        }
      }
      div(:class => 'clear')
    }
    :horizontal # Sort direction
  end
  
  def show_preview
    case @items_size
    when 1
      view_mode = 'large'
    when 2
      view_mode = 'medium'
    when 3
      view_mode = 'small'
    end
    div(:class => "main_preview#{@items_size} sortable") {
      @items.each_with_index { |item, index|  
        klass = (index + 1) == @items_size ? 'element last' : 'element'
        div(:class => klass, :id => sort_id(item)) {
          sort_handle
          show_item(item, view_mode)
        }
      }
      div(:class => 'clear')
    }
    :horizontal # Sort direction
  end

  def show_index
    div(:class => 'index sortable') {
      @items.each_with_index { |item, index|  
        klass = index.odd? ? 'element preview-even' : 'element preview-odd'
        div(:class => klass, :id => sort_id(item)) {
          sort_handle
          show_item(item, 'small')
        }
      }
    }
    :vertical # Sort direction
  end
  
  def is_articles_index?
    @is_articles_index ||= get_acts_as_articles_index
  end
  
  def add_new_item
    begin
      target_node_id = @args_hash[:options][:target_node_id]
      resource = TreeNode.find(target_node_id).resource
      add_node_link_to_resource(tree_node, resource)
    rescue Exception => e
    end
  end
  
  def get_content_items
    @items = content_items(tree_node.id)
    @items_size = @items.size
    @widget_id = tree_node.id
    @widget_name = tree_node.resource.resource_type.hrid
    @is_main_format = get_is_main_format == '' ? false : get_is_main_format 
    @max_num = get_maximum_number_of_items.to_i
    if get_maximum_number_of_items.to_i > 3 && !is_articles_index?
      @max_num = 3
    end
  end
  
  def render_content_item(tree_node, view_mode)
    klass = tree_node.resource.resource_type.hrid
    return w_class(klass).new(:tree_node => tree_node, :view_mode => view_mode).render_to(self)
  end

  def content_items(node_id)
    TreeNode.get_subtree(
      :parent => node_id, 
      :resource_type_hrids => ['content_page', 'custom_preview'], 
      :depth => 1,
      :has_url => false,
      #:is_main => false,
      :status => ['PUBLISHED', 'DRAFT']
    )               
  end
  
  def show_item(item, view_mode)
    if item.resource.status == 'DRAFT'
      div(:class => 'draft') { render_content_item(item, view_mode) }
    else
      render_content_item(item, view_mode)
    end
  end
  
end
