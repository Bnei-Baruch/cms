class Hebmain::Widgets::ContentPreview < WidgetManager::Base

  def render_full
    get_content_items
    div(:class => 'content_preview'){
      w_class('cms_actions').new(:tree_node => tree_node, 
        :options => {:buttons => %W{new_button edit_button delete_button},
          :button_text => 'ניהול תצוגה מקדימה', 
          :new_text => 'הוספת יחידה בצורה ידנית', 
          :has_url => false,
          :resource_types => %W{ custom_preview }}).render_to(self)
    
      # Set the updatable div  - THIS DIV MUST BE AROUND THE CONTENT TO BE UPDATED.
      updatable = 'up-' + @widget_id.to_s
      div(:id => updatable){
        render_preview_update
      }
      if !@is_main_format
        w_class('cms_actions').new(:tree_node => tree_node, :view_mode => 'tree_drop_zone', :options => {:page_url => get_page_url(presenter.node), :updatable => updatable, :updatable_view_mode => 'preview_update'}).render_to(self)
      end
    }
  end

  # This function is initiated also in Ajax request
  def render_preview_update
    get_content_items
    max_num = get_maximum_number_of_items.to_i
    if get_maximum_number_of_items.to_i > 3 && !is_articles_index?
      max_num = 3
    end
    if @items_size < max_num
      add_new_item
      get_content_items
    end
    
    if @is_main_format
      show_main_format
    else
      if is_articles_index?
        show_index
      else
        show_preview
      end
    end
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
    div(:class => "main_preview#{@items_size}") {
      @items.each_with_index { |item, index|  
        klass = (index + 1) == @items_size ? 'element last' : 'element'
        div(:class => klass) {
          render_content_item(item, view_mode)
        }
      }
      div(:class => 'clear')
    }
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
    div(:class => "main_preview#{@items_size}") {
      @items.each_with_index { |item, index|  
        klass = (index + 1) == @items_size ? 'element last' : 'element'
        div(:class => klass) {
          render_content_item(item, view_mode)
        }
      }
      div(:style => 'clear: right;')
    }                  
  end

  def show_index
    div(:class => 'index') {
      @items.each_with_index { |item, index|  
        klass = index.odd? ? 'element preview-even' : 'element preview-odd'
        div(:class => klass) {
          render_content_item(item, 'small')
        }
      }
    }
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
    @items = content_items
    @items_size = @items.size
    @widget_id = tree_node.id
    @widget_name = tree_node.resource.resource_type.hrid
    @is_main_format = get_is_main_format == '' ? false : get_is_main_format 
  end
  
  def render_content_item(tree_node, view_mode)
    klass = tree_node.resource.resource_type.hrid
    return w_class(klass).new(:tree_node => tree_node, :view_mode => view_mode).render_to(self)
  end

  def content_items
    TreeNode.get_subtree(
      :parent => tree_node.id, 
      :resource_type_hrids => ['content_page', 'custom_preview'], 
      :depth => 1,
      :has_url => false,
      #:is_main => false,
      :status => ['PUBLISHED', 'DRAFT']
    )               
  end
end
