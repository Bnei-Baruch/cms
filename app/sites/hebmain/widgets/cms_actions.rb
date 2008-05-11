class Hebmain::Widgets::CmsActions < WidgetManager::Base



  # tree_node - is the node object to which the operations will be performed. Editing will be for this object, New is a new child for this object, Delete is deleting this tree_node
  def render_full
    # operations permitted only on tree nodes other than the page you are on now.
    if @options
      if tree_node.can_create_child? && @options[:buttons].include?('new_button')
        new_button
      end
      if tree_node.can_edit? && @options[:buttons].include?('edit_button')
        edit_button
      end
      if tree_node.can_delete? && @options[:buttons].include?('delete_button')
        delete_button
      end
    end         
  end

  def new_button
    parent_id = tree_node.id
    resource_types = []
    @options[:resource_types].each{|e|
      resource_types << ResourceType.get_resource_type_by_hrid(e)
    }
    is_main = @options[:is_main] || true
    has_url = @options[:has_url]
    placeholder = @options[:placeholder] || ''
    new_text = @options[:new_text] || 'חדש'
    if parent_id && !resource_types.empty?
      span(:class => 'action_buttons'){
        if resource_types.size > 1
          new_button_form(resource_types, parent_id, is_main, has_url, placeholder, new_text)
        else
          new_button_link(resource_types, parent_id, is_main, has_url, placeholder, new_text)
        end
      }
    end
  end

  def edit_button
    span(:class => 'action_buttons'){
      a 'ערוך', :href => edit_admin_resource_path(:id => tree_node.resource, :tree_id => tree_node.id), :title => 'ערוך אובייקט', :class => 'edit_button'
    }
  end

  def delete_button
    span(:class => 'action_buttons'){
      rawtext <<-code
      <a onclick="if (confirm('Are you sure?')) { var f = document.createElement('form'); f.style.display = 'none'; this.parentNode.appendChild(f); f.method = 'POST'; f.action = this.href;var m = document.createElement('input'); m.setAttribute('type', 'hidden'); m.setAttribute('name', '_method'); m.setAttribute('value', 'delete'); f.appendChild(m);f.submit(); };return false;" href="#{admin_tree_node_path(tree_node)}" class="delete_button">מחק</a>
      code
    }
  end

  private

  def new_button_link(resource_types, parent_id, is_main, has_url, placeholder, new_text)
    a new_text, :href => new_admin_resource_path(
    :resource => {
      :resource_type_id => resource_types.first.id, 
      :tree_node => {:parent_id => parent_id, :is_main => is_main, :has_url => has_url, :placeholder => placeholder}
    }
    ), :title => 'צור חדש', :class => 'new_button'

  end

  def new_button_form(resource_types, parent_id, is_main, has_url, placeholder, new_text)
    form(:method => 'get', :action => new_admin_resource_path) {
      select(:name => 'resource[resource_type_id]', :id => 'resource[resource_type_id]') {
        resource_types.each{ |e|
          option e.name, :value => e.id
        }
      }
      input(:type => 'hidden', :name => 'resource[tree_node][parent_id]', :value => parent_id)
      input(:type => 'hidden', :name => 'resource[tree_node][is_main]', :value => is_main)
      input(:type => 'hidden', :name => 'resource[tree_node][has_url]', :value => has_url)
      input(:type => 'hidden', :name => 'resource[tree_node][placeholder]', :value => placeholder)
      input(:type => 'submit', :name => 'commit', :value => new_text)
    }
  end

end