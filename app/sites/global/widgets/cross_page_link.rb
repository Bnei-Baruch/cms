class Global::Widgets::CrossPageLink < WidgetManager::Base

  def render_full
    div(:class => 'cross_page_link'){
      w_class('cms_actions').new(:tree_node => tree_node, :options => {
          :buttons => %W{ delete_button edit_button },
          :button_text => _(:cross_page_link),
          :position => 'bottom'}).render_to(self)
      sort_handle
      # Set the updatable div  - THIS DIV MUST BE AROUND THE CONTENT TO BE UPDATED.
      updatable = 'up-' + tree_node.id.to_s
      div(:id => updatable){
        show_link
      }

      w_class('cms_actions').new(:tree_node => tree_node, :view_mode => 'tree_drop_zone',
        :options => {
          :page_url => get_page_url(presenter.node),
          :updatable => updatable,
          :updatable_view_mode => 'preview_update'
        }).render_to(self)
    }
  end

  # This function is initiated also in Ajax request
  def render_preview_update
    begin
      target_node_id = @args_hash[:options][:target_node_id]
      tree_node.resource.properties('link').value = TreeNode.find(target_node_id).permalink
      tree_node.resource.save!
    rescue Exception => e
    end
    show_link
  end

  private
  def show_link
    a(:href=> get_link){
      text get_title
    }
  end
end
