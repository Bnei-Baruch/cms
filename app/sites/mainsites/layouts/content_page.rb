class Mainsites::Layouts::ContentPage < WidgetManager::Layout

  attr_accessor :ext_content, :ext_content_header, :ext_title, :ext_description,
    :ext_main_image, :ext_related_items, :ext_kabtv_exist

  def initialize(*args, &block)
    super
    @header_top_links = w_class('header').new(:view_mode => 'top_links')
    @header_bottom_links = w_class('header').new(:view_mode => 'bottom_links')
    @header_logo = w_class('header').new(:view_mode => 'logo')
    @header_copyright = w_class('header').new(:view_mode => 'copyright')
    @static_tree = w_class('tree').new(:view_mode => 'static')
    @dynamic_tree = w_class('tree').new(:view_mode => 'dynamic', :display_hidden => true)
    @breadcrumbs = w_class('breadcrumbs').new()
    @titles = w_class('breadcrumbs').new(:view_mode => 'titles')
    @meta_title = w_class('breadcrumbs').new(:view_mode => 'meta_title')
    @google_analytics = w_class('google_analytics').new
    @newsletter = w_class('newsletter').new(:view_mode => 'sidebar')
    @sitemap = w_class('sitemap').new
    @send_to_friend = w_class('send_to_friend').new
    @direct_link = w_class('shortcut').new
    @subscription = w_class('header').new(:view_mode => 'subscription')
    @comments = w_class('comments').new
  end

  def render
    rawtext '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">'
    html("xmlns" => "http://www.w3.org/1999/xhtml", "xml:lang" => "en", "lang" => "en") {
      head {
        meta "http-equiv" => "content-type", "content" => "text/html;charset=utf-8"
        meta "http-equiv" => "Content-language", "content" => "utf8"
        meta(:name => 'node_id', :content => @tree_node.id)
        meta(:name => 'description', :content => ext_description)
        title @meta_title #ext_title
        javascript_include_tag 'flashembed.min.js', 'embed', 'jquery',
        'ui/ui.core.min.js', 'ui/ui.tabs.min.js', 'ui/jquery.color.js',
        'jq-helpers', 'jquery.curvycorners.packed.js', 'jquery.browser.js',
        'jquery.media.js', 'jquery.metadata.js','jquery.form.js',
        '../highslide/highslide-full.packed.js',
        'jquery-lightbox/jquery.lightbox.js' #, :cache => 'cache/content_page'

        if presenter.node.can_edit?
          stylesheet_link_tag 'reset-fonts-grids', 
          'base-min', 
          '../ext/resources/css/ext-all', 
          'hebmain/common',
          'hebmain/header', 
          'hebmain/inner_page', 
          'hebmain/page_admin',
          'hebmain/jquery.tabs.css',
          'hebmain/widgets',
          '../highslide/highslide',
          'lightbox',
          :cache => false
          #:cache => 'cache/content_page_admin'
          javascript_include_tag '../ext/adapter/ext/ext-base', '../ext/ext-all', 'ext-helpers',
          'ui/ui.sortable.min.js', 'ui/ui.draggable.min.js', 'ui/ui.droppable.min.js'
          javascript {
            rawtext 'Ext.BLANK_IMAGE_URL="/ext/resources/images/default/s.gif";'
            rawtext 'Ext.onReady(function(){Ext.QuickTips.init()});'
          }
        else
          stylesheet_link_tag 'reset-fonts-grids', 
          'base-min', 
          '../ext/resources/css/ext-all', 
          'hebmain/common',
          'hebmain/header', 
          'hebmain/inner_page', 
          'hebmain/jquery.tabs.css',
          'hebmain/widgets',
          '../highslide/highslide',
          'lightbox',
          :cache => 'cache/content_page',
          :media => 'all'
          
          stylesheet_link_tag 'hebmain/print',
          :media => 'print'
        end
        
        rawtext "\n<!--[if IE 6]>\n"
        stylesheet_link_tag 'hebmain/ie6', :media => 'all'
        stylesheet_link_tag 'hebmain/ie6_print', :media => 'print'
        rawtext "\n<![endif]-->\n"

        rawtext "\n<!--[if IE 7]>\n"
        stylesheet_link_tag 'hebmain/ie6', :media => 'all'
        stylesheet_link_tag 'hebmain/ie7', :media => 'all'
        rawtext "\n<![endif]-->\n"
      }
      body {
        div(:id => 'doc2', :class => 'yui-t4') {
          div(:id => 'bd') {
            div(:id => 'yui-main') {
              div(:class => 'yui-b') {
                div(:class => 'yui-ge') {
                  @dynamic_tree.render_to(doc)
                  div(:id => 'hd') {
                    make_sortable(:selector => '#hd .links', :axis => 'x') {
                      @header_top_links.render_to(self)
                    }
                  }
                  div(:class => 'menu') {
                    w_class('sections').new.render_to(self)
                  }
                  div(:class => 'margin-25') {text ' '}
                  div(:class => 'middle'){
                    div(:class => 'h1') {
                      @titles.render_to(doc)
                      div(:class =>'h1-right')
                      div(:class =>'h1-left')
                    }
                    @breadcrumbs.render_to(self) 
                    div(:class => 'margin-25') {text ' '}
                  }
                  div(:class => 'content-header') {
                    make_sortable(:selector => ".content-header", :axis => 'y') {
                      self.ext_content_header.render_to(doc)
                    }
                  }
                  div(:class => 'yui-u first') {
                    div(:class => 'content') {
                      make_sortable(:selector => ".content", :axis => 'y') {
                        self.ext_content.render_to(doc)
                      }
                      @subscription.render_to(self)
                      div(:class => 'clear')
                      
                      @send_to_friend.render_to(self)
                      @direct_link.render_to(self) 

                      #if @presenter.site_settings[:comments][:enable_site_wide]
                      @comments.render_to(self)
                      #end
                      
                      if ext_kabtv_exist
                          div(:id => 'ft'){
                            @header_bottom_links.render_to(self)
                            @header_copyright.render_to(self)
                          }
                      end

                    }
                  }
                  div(:class => 'yui-u') {
                    div(:class => 'related') {
                      self.ext_main_image.render_to(doc)
                      make_sortable(:selector => ".related", :axis => 'y') {
                        self.ext_related_items.render_to(doc)
                      }
                    }
                  }
                }
              }
            }
            div(:class => 'yui-b') {
              div(:id => 'hd-r') { @header_logo.render_to(self) } #Logo goes here
              div(:class => 'nav') {
                div(:class => 'h1') {
                  text presenter.main_section.resource.name if presenter.main_section
                  div(:class =>'h1-right')
                  div(:class =>'h1-left')
                }
                @static_tree.render_to(doc)
              }
           		
              @newsletter.render_to(self)
              
              global_site_updates.each{|e|
                  render_content_resource(e)
              } 
            }
        }
        
          div(:id => 'ft') {
            @sitemap.render_to(self)
            make_sortable(:selector => '#ft .links', :axis => 'x') {
              @header_bottom_links.render_to(self)
            }
            @header_copyright.render_to(self)
          } unless ext_kabtv_exist
        }
        @google_analytics.render_to(self)
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
  end
  
end 
