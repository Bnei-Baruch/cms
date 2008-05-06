class Hebmain::Widgets::Breadcrumbs < WidgetManager::Base
  def render_full
    @tree_node ||= presenter.node
    div(:class => 'breadcrumbs') {
      unless parents.empty?
        parents.reverse.each_with_index{ |e, i|
          name = e.resource.name
          a(:href => get_page_url(e), :title => name) { text name }
          span(:class => 'gt') {text ' > '}
        }
      end
      text @tree_node.resource.name
    }

  end

  private

  def parents
    presenter.parents(@tree_node) || []
  end
end