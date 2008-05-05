class Hebmain::Widgets::Header < Widget::Base
  
  def render
    div(:class => 'logo') do
      img(:src => img_path('logo.gif'), :alt => 'Title')
    end
    
    div(:class => 'search') do
      img(:src => img_path('search.gif'), :alt => 'Search')
      input(:name => 'search')
      span 'חיפוש:'
    end
    ul(:class => 'links') do      
      external_sections.each do |e|
        li do
          w_class('link').new(:tree_node => e).render_to(self)
        end
      end
    end
    
    
  end
  
  
  private
  
  def external_sections
    TreeNode.get_subtree(
    :parent => presenter.website_node.id, 
    :resource_type_hrids => ['link'], 
    :depth => 1,
    :has_url => false
    )               
  end    
end
