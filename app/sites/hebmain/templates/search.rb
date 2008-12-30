class Hebmain::Templates::Search < WidgetManager::Template

  def set_layout
    layout.ext_content = ext_content
    layout.ext_content_header = ext_content_header
    layout.ext_title = ext_title
    layout.ext_description = ext_description
    layout.ext_main_image = ext_main_image
    layout.ext_related_items = ext_related_items
  end
  
  def ext_content_header
    WidgetManager::Base.new(helpers) do
    end
  end
  def ext_content
    WidgetManager::Base.new(helpers) do

      h1 get_title if get_title
            
      div(:id => "cse-search-results")
      
      javascript {
        rawtext <<-SCRIPT_CODE
          var googleSearchIframeName = "cse-search-results";
          var googleSearchFormName = "cse-search-box";
          var googleSearchFrameWidth = 520;
          var googleSearchDomain = "www.google.com";
          var googleSearchPath = "/cse";
        SCRIPT_CODE
      }
      #        <script type="text/javascript" src="http://www.google.com/afsonline/show_afs_search.js"></script>
      javascript {
        rawtext <<-google
$(document).ready(function(){
   $.getScript('http://www.google.com/afsonline/show_afs_search.js', function(){
   }, true);
});
        google
      }

    end
  end

  def ext_title
    WidgetManager::Base.new do
      text get_name
    end
  end

  def ext_description
    WidgetManager::Base.new do
      text get_description
    end
  end

  def ext_meta_title
    WidgetManager::Base.new do
      #  text get_name# unless get_hide_name
      w_class('breadcrumbs').new(:view_mode => 'meta_title') 
    end
  end

  def ext_main_image
    WidgetManager::Base.new do
      if get_main_image && !get_main_image.empty?
        div(:class => 'image'){
          img(:src => get_main_image, :alt => get_main_image_alt, :title => get_main_image_alt)
          text get_main_image_alt
        }
      end                
    end
  end

  def ext_related_items
    WidgetManager::Base.new do
      w_class('cms_actions').new(:tree_node => @tree_node, :options => {:buttons => %W{ new_button }, :resource_types => %W{ box },:new_text => 'צור קופסא חדשה', :has_url => false, :placeholder => 'related_items', :position => 'bottom'}).render_to(self)
      show_content_resources(:resources => related_items)
    end
  end

  private

  def render_related_item(tree_node)
    class_name = tree_node.resource.resource_type.hrid
    return w_class(class_name).new(:tree_node => tree_node).render_to(self)
  end

  def related_items
    TreeNode.get_subtree(
      :parent => tree_node.id, 
      :resource_type_hrids => ['box'], 
      :depth => 1,
      :has_url => false,
      :placeholders => ['related_items'],
      :status => ['PUBLISHED', 'DRAFT']
    )               
  end

end