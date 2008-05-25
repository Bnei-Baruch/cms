class Hebmain::Widgets::Header < WidgetManager::Base
  
  def render_top_links
    div(:class => 'search') do
      img(:src => img_path('search.gif'), :alt => 'Search')
      input(:name => 'search')
    end
    ul(:class => 'links') do
      w_class('cms_actions').new(:tree_node => presenter.website_node, :options => {:buttons => %W{ new_button }, :resource_types => %W{ link },:new_text => 'לינק חדש', :has_url => false, :placeholder => 'top_links'}).render_to(self)
      top_links.each do |e|
        li do
          w_class('link').new(:tree_node => e, :view_mode => 'with_image').render_to(self)
        end
      end
    end
  end

  def render_bottom_links
      w_class('cms_actions').new(:tree_node => presenter.website_node, 
                                 :options => {:buttons => %W{ new_button }, 
                                              :resource_types => %W{ link },:new_text => 'לינק חדש לפוטר', 
                                              :has_url => false, 
                                              :placeholder => 'bottom_links'
                                              }).render_to(self)
      ul(:class => 'links') do
      bottom_links.each_with_index do |e, i|
        rawtext '&nbsp;&nbsp;|&nbsp;&nbsp;' unless i.eql?(0)
        li do
          w_class('link').new(:tree_node => e).render_to(self)
        end
      end
    end
  end
  
  def render_logo
    div(:class => 'logo') do
      h1 'קבלה לעם'
      img(:src => img_path('logo.gif'), :alt => 'Title')
    end
  end
  
  private
  
  def top_links
    @top_links ||= 
    TreeNode.get_subtree(
      :parent => presenter.website_node.id, 
      :resource_type_hrids => ['link'], 
      :depth => 1,
      :placeholders => 'top_links',
      :has_url => false
    )               
  end    
  def bottom_links
    bottom_links ||=
    TreeNode.get_subtree(
      :parent => presenter.website_node.id, 
      :resource_type_hrids => ['link'], 
      :depth => 1,
      :placeholders => 'bottom_links',
      :has_url => false
    )               
  end    
end
