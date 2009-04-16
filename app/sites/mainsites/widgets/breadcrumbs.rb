class Mainsites::Widgets::Breadcrumbs < WidgetManager::Base
  def render_full
    div(:class => 'breadcrumbs') { 
      a(:href => presenter.home ) {text _(:'home_breadcrumb')}
      span(:class => 'gt') {text ' > '}
      unless parents.empty?
        parents.reverse_each{ |e, i|
          name = e.resource.name
          a(:href => get_page_url(e), :title => name) { text name }
          span(:class => 'gt') {text ' > '}
        }
      end
      text @tree_node.resource.name
    }

  end
  
  def render_meta_title  
    title = ''
    
    meta_title = @tree_node.resource.properties("meta_title").get_value rescue nil
    if !meta_title || meta_title.empty?
      meta_title = @tree_node.resource.name
    end
    title = title + meta_title 
    
    unless parents.empty?
      parents.each{ |e|
        meta_title = e.resource.properties("meta_title").get_value rescue nil
        if !meta_title || meta_title.empty?
        	meta_title = e.resource.name
        end
	  	
        title = title + ' | ' + meta_title
      }
    end  
    
    text title
  end
  
  def render_titles
    unless calculated_titles.empty?
      calculated_titles.reverse.each_with_index{ |e, i|
        text e.resource.name
        text ' | ' unless calculated_titles.size == (i + 1)
      }
    end
  end

  private

  def calculated_titles
    return @calculated_titles if @calculated_titles
    rp = @tree_node.resource.properties('acts_as_section')
    last_item = rp && rp.get_value ?  [@tree_node] : []
    @calculated_titles ||= last_item + parents.reject{|e| e.eql?(presenter.main_section)}
  end

  def parents
    presenter.parents(@tree_node) || []
  end
  

end