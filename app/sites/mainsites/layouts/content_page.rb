class Mainsites::Layouts::ContentPage < WidgetManager::Layout

  attr_accessor :ext_content, :ext_content_header, :ext_title, :ext_description,
    :ext_main_image, :ext_related_items, :ext_kabtv_exist

  def initialize(*args, &block)
    super
    @header_search = w_class('header').new(:view_mode => 'search')
    @header_top_links_ext = w_class('header').new(:view_mode => 'top_links_ext')
    @header_top_links_int = w_class('header').new(:view_mode => 'top_links_int')
    @header_top_languages = w_class('header').new(:view_mode => 'top_languages')
    @header_bottom_links = w_class('header').new(:view_mode => 'bottom_links')
    @header_logo = w_class('header').new(:view_mode => 'logo')
    @header_copyright = w_class('header').new(:view_mode => 'copyright')
    @static_tree = w_class('tree').new(:view_mode => 'static_ltr')
    @dynamic_tree = w_class('tree').new(:view_mode => 'dynamic', :display_hidden => true)
    @breadcrumbs = w_class('breadcrumbs').new()
    @titles = w_class('breadcrumbs').new(:view_mode => 'titles')
    @meta_title = w_class('breadcrumbs').new(:view_mode => 'meta_title')
    #    @google_analytics = w_class('google_analytics').new
    @newsletter = w_class('newsletter').new(:view_mode => 'sidebar')
    @sitemap = w_class('sitemap').new
    @send_to_friend = w_class('send_to_friend').new
    @direct_link = w_class('shortcut').new
    @subscription = w_class('header').new(:view_mode => 'subscription')
    @comments = w_class('comments').new
    @previous_comments = w_class('comments').new(:view_mode => 'previous')
  end

  def render
    rawtext '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">'
    html("xmlns" => "http://www.w3.org/1999/xhtml", "xml:lang" => "en", "lang" => "en") {
      head {
        meta "http-equiv" => "content-type", "content" => "text/html;charset=utf-8"
        meta "http-equiv" => "Content-language", "content" => "utf8"
        title @meta_title
        meta(:name => 'description', :content => ext_description)
        javascript_include_tag 'jquery', 
        'ui/ui.core.min.js', 'ui/ui.tabs.min.js', 'ui/jquery.color.js',
        'jquery.curvycorners.packed.js', 'jquery.browser.js',
        'jquery.hoverIntent.min.js', 'superfish',
        'flashembed.min.js', 'jq-helpers' #, :cache => 'cache/website'
        if presenter.node.can_edit?
          stylesheet_link_tag 'common/reset.css',
          '../ext/resources/css/ext-all',
          'rusmain/common.css',
          'rusmain/content_page.css',
          'rusmain/page_admin',
          'rusmain/jquery.tabs.css',
          'rusmain/superfish.css',
          :cache => false
          javascript_include_tag '../ext/adapter/ext/ext-base', '../ext/ext-all', 'ext-helpers',
          'ui/ui.sortable.min.js', 'ui/ui.draggable.min.js', 'ui/ui.droppable.min.js'
          javascript {
            rawtext 'Ext.BLANK_IMAGE_URL="/ext/resources/images/default/s.gif";'
          }
        else
          stylesheet_link_tag 'common/reset.css',
          'rusmain/common.css',
          'rusmain/content_page.css',
          'rusmain/superfish.css',
          'rusmain/jquery.tabs.css'
          #,
          #:cache => 'cache/website'
        end

        rawtext '<!--[if IE]>'
        stylesheet_link_tag 'rusmain/ie6'
        rawtext '<![endif]-->'
      }
      body {
        if presenter.node.can_edit?
          div(:id => 'command-panel'){
            @dynamic_tree.render_to(self)
            div(:class => 'clear')
          }
          header_class = 'under-command-panel'
        end
        div(:id => 'header', :class => header_class){
          @header_logo.render_to(self)
          @header_search.render_to(self)
          div(:id => 'links'){
            make_sortable(:selector => '#header .links_ext', :axis => 'x') {
              @header_top_links_ext.render_to(self)
            }
            make_sortable(:selector => '#header .links_int', :axis => 'x') {
              @header_top_links_int.render_to(self)
            }
          }
          @header_top_languages.render_to(self)
        }
        div(:id => 'nav-empty'){
          nbsp
        }
        div(:id => 'nav'){
          div(:class => 'left-ear')
          div(:class => 'right-ear')

          w_class('sections').new.render_to(self)
        }
        div(:id => 'body'){
          div(:id => 'body-left'){
            div(:class => 'side-box-top'){
              rawtext 'Kabbalah for Beginners'
              div(:class => 'left-ear')
              div(:class => 'right-ear')
            }
            div(:class => 'box-content'){
              @static_tree.render_to(self)
            }
            div(:class => 'side-box'){
              h3 'Newsletter'
              div(:class => 'box-content'){
                @newsletter.render_to(self)
              }
            }
            div(:class => 'side-box'){
              h3 'Updates'
              div(:class => 'box-content'){
                rawtext 'Bold headline'
                br
                rawtext 'A few lines of text A few lines of text A few lines of text A few lines of text A few lines of text A few lines of text '
                br
                a(:href => ''){rawtext 'A link to something'}
              }
            }
          }
          div(:id => 'body-middle'){
            div(:class => 'mid-box-top'){
              @titles.render_to(self)
              div(:class => 'left-ear')
              div(:class => 'right-ear')
            }
            div(:id => 'content-header'){
              make_sortable(:selector => ".content-header", :axis => 'y') {
                self.ext_content_header.render_to(self)
              }
            }
            div(:id => 'mid-content'){
              @breadcrumbs.render_to(self)
              div(:class => 'related') {
                self.ext_main_image.render_to(self)
                make_sortable(:selector => ".related", :axis => 'y') {
                  self.ext_related_items.render_to(self)
                }
              }
              make_sortable(:selector => ".mid-content", :axis => 'y') {
                self.ext_content.render_to(self)
              }
              @subscription.render_to(self)
              div(:class => 'clear')

              @comments.render_to(self)
              @send_to_friend.render_to(self)
              @direct_link.render_to(self)

              @previous_comments.render_to(self)
            }
          }
        }
        div(:id => 'footer'){
          @sitemap.render_to(self)
          make_sortable(:selector => '#footer .links', :axis => 'x') {
            @header_bottom_links.render_to(self)
          }
          @header_copyright.render_to(self)
        } unless ext_kabtv_exist
        #        @google_analytics.render_to(self)
      }
    }
  end
  
  private
  
  def right_column_resources
    @tree_nodes_right ||= TreeNode.get_subtree(
      :parent => tree_node.id,
      :resource_type_hrids => ['site_updates', 'video_gallery'],
      :depth => 1,
      :placeholders => ['right'],
      :status => ['PUBLISHED', 'DRAFT']
    )
  end
  
  def left_column_resources
    @tree_nodes_left ||= TreeNode.get_subtree(
      :parent => tree_node.id,
      :resource_type_hrids => ['rss'],
      :depth => 1,
      :placeholders => ['left'],
      :status => ['PUBLISHED', 'DRAFT']
    )
  end
  
  def middle_column_resources
    @tree_nodes_middle ||= TreeNode.get_subtree(
      :parent => tree_node.id,
      :resource_type_hrids => ['content_preview', 'title'],
      :depth => 1,
      :placeholders => ['middle'],
      :status => ['PUBLISHED', 'DRAFT']
    )
  end
  
  def kabbalah_media_resources
    @kabbalah_media_nodes ||= TreeNode.get_subtree(
      :parent => tree_node.id,
      :resource_type_hrids => ['media_rss'],
      :depth => 1,
      :placeholders => ['lesson'],
      :status => ['PUBLISHED', 'DRAFT']
    )
  end

  def kabtv_resources
    @kabtv_nodes ||= TreeNode.get_subtree(
      :parent => tree_node.id,
      :resource_type_hrids => ['kabtv'],
      :depth => 1,
      :placeholders => ['home_kabtv'],
      :status => ['PUBLISHED', 'DRAFT']
    )
  end

end 
