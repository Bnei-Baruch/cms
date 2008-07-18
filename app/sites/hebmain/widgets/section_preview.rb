class Hebmain::Widgets::SectionPreview < WidgetManager::Base

  def render_full
    w_class('cms_actions').new(:tree_node => tree_node, :options => {:buttons => %W{ delete_button  edit_button }}).render_to(doc)
    
    # Set the updatable div  - THIS DIV MUST BE AROUND THE CONTENT TO BE UPDATED.
    updatable = 'up-' + tree_node.id.to_s
    div(:id => updatable){
      show_section
    }
    w_class('cms_actions').new(:tree_node => tree_node, :view_mode => 'tree_drop_zone', :options => {:page_url => get_page_url(presenter.node), :updatable => updatable, :updatable_view_mode => 'preview_update'}).render_to(self)
  end

  # This function is initiated also in Ajax request
  def render_preview_update
    # debugger
    add_new_section
    show_section
  end
  
  
  private
  
  def show_section
    if section.size == 1
      div(:class => 'section_preview') {
        div(:class => 'h1') {
          text get_title.empty? ? section[0].resource.name : get_title
          a(:class => 'cont', :href => get_page_url(section_main_node)) {
            text get_read_more_link.empty? ? 'לכל הכתבות' : get_read_more_link
            img(:src => img_path('arrow-left.gif'), :alt => '')
          }
          div(:class =>'h1-right')
          div(:class =>'h1-left')
        }
        show_index
      }
    end
  end
  
  def show_index
    div(:class => 'index') {
      content_items.each_with_index { |item, index|  
        klass = index.odd? ? 'element preview-even' : 'element preview-odd'
        div(:class => klass) {
          show_item(item, 'small')
          div(:class => 'clear')
        }
        div(:class => 'clear')
      }
    }
  end
  
  def section_main_node
    section[0].main
  end
  
  def add_new_section
    if section.size >= 1
      section.each{|e| remove_link_from_resource(e)}
    end
    begin
      target_node_id = @args_hash[:options][:target_node_id]
      resource = TreeNode.find(target_node_id).resource
      add_node_link_to_resource(tree_node, resource)
    rescue Exception => e
    end                
  end
  
  def section
    TreeNode.get_subtree(
    :parent => tree_node.id, 
    :resource_type_hrids => ['content_page'], 
    :depth => 1,
    :has_url => false,
    :is_main => false,
    :status => ['PUBLISHED', 'DRAFT']
    )               
  end

  def content_items
    @content_items ||=
    TreeNode.get_subtree(
    :parent => section_main_node.id, 
    :resource_type_hrids => ['content_page'], 
    :depth => 1,
    :has_url => true,
    :order => "created_at DESC",
    :limit => get_number_of_items,
    # :properties => 'b_acts_as_section = false', ### - this will filter only the pages that are not sections
    :status => ['PUBLISHED']
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