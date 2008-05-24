class Mainsites::Layouts::ContentPage < WidgetManager::Layout

  attr_accessor :ext_content, :ext_title, :ext_main_image, :ext_related_items

  def initialize(*args, &block)
    super
    @header_left = w_class('header').new(:view_mode => 'left')
    @header_right = w_class('header').new(:view_mode => 'right')
    @static_tree = w_class('tree').new(:view_mode => 'static')
    @dynamic_tree = w_class('tree').new(:view_mode => 'dynamic', :display_hidden => true)
    @breadcrumbs = w_class('breadcrumbs').new()
    @titles = w_class('breadcrumbs').new(:view_mode => 'titles')
  end

  def render
    rawtext '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">'
    html("xmlns" => "http://www.w3.org/1999/xhtml", "xml:lang" => "en", "lang" => "en") {
      head {
        meta "http-equiv" => "content-type", "content" => "text/html;charset=utf-8"
        meta "http-equiv" => "Content-language", "content" => "utf8"
        title ext_title
        # css(get_css_external_url('reset-fonts-grids'))
        # css(get_css_external_url('base-min'))
        # css(get_css_external_url('../ext/resources/css/ext-all'))
        # css(get_css_url('header'))
        # css(get_css_url('inner_page'))
        # css(get_css_url('page_admin'))
        stylesheet_link_tag 'reset-fonts-grids', 
                            'base-min',
                            '../ext/resources/css/ext-all', 
                            get_css_url('header'), 
                            get_css_url('inner_page'),
                            get_css_url('page_admin')
        javascript_include_tag '../ext/adapter/ext/ext-base', '../ext/ext-all-debug', 'ext-helpers'
        javascript {
          rawtext 'Ext.util.CSS.swapStyleSheet("theme","ext/resources/css/xtheme-gray.css");'
          rawtext 'Ext.BLANK_IMAGE_URL="/ext/resources/images/default/s.gif";'
        }
      }
      body {
        div(:id => 'doc2', :class => 'yui-t4') {
          div(:id => 'bd') {
            div(:id => 'yui-main') {
              div(:class => 'yui-b') {
                div(:class => 'yui-ge') {
                  @dynamic_tree.render_to(doc)
                  div(:id => 'hd') { @header_left.render_to(self) } #Header goes here
                  div(:class => 'menu') {
                    w_class('sections').new.render_to(self)
                  }    
                  div(:class => 'h1') {
                    @titles.render_to(doc)
                    img(:src => img_path('top-right.gif'),:class =>'h1-right-blue', :alt => '')
                    img(:src => img_path('top-left.gif'),:class =>'h1-left-blue', :alt => '')
                  }
                  @breadcrumbs.render_to(self) 
                  div(:class => 'yui-u first') {
                    div(:class => 'content') { self.ext_content.render_to(doc) }
                  }
                  div(:class => 'yui-u') {
                    div(:class => 'related') {
                      self.ext_main_image.render_to(doc)
                      self.ext_related_items.render_to(doc)
                    }
                  }
                }
              }
            }
            div(:class => 'yui-b') {
              div(:id => 'hd-r') { @header_right.render_to(self) } #Logo goes here
              div(:class => 'nav') {
                h4 {
                  img(:src => img_path('top-right.gif'), :class => 'right', :alt => '')
                  img(:src => img_path('top-left.gif'), :class => 'left', :alt => '')
                  text presenter.main_section.resource.name if presenter.main_section
                }
                @static_tree.render_to(doc)
              }
              
              global_site_updates_node = global_site_updates
              render_content_resource(global_site_updates_node, 'news') if global_site_updates_node
#              w_class('cms_actions').new(:tree_node => tree_node, 
#                :options => {:buttons => %W{ new_button }, 
#                  :resource_types => %W{ site_updates },
#                  :new_text => 'צור יחידת תוכן חדשה', 
#                  :has_url => false, 
#                  :placeholder => 'right'}).render_to(self)
#                
#              right_column_resources.each { |right_column_resource|                
#                render_content_resource(right_column_resource,
#                    right_column_resource.resource.resource_type.hrid == 'site_updates' ? 'news' : 'full')
#              }                
            }
          }
          div(:id => 'ft') {
            # text 'Footer'
          }
        }
      }
    }
  end  
  
  private 
  
  def right_column_resources
    @tree_nodes ||= TreeNode.get_subtree(
      :parent => tree_node.id, 
      :resource_type_hrids => ['site_updates'], 
      :depth => 1,
      :placeholders => ['right']
    ) 
  end
  
    def global_site_updates
    @site_updates ||= TreeNode.get_subtree(
      :parent => presenter.website_node.id, 
      :resource_type_hrids => ['site_updates'], 
      :depth => 1,
      :placeholders => ['right']
    )
    return @site_updates ? @site_updates[0] : nil
  end
  
end 
