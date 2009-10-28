class Mainsites::Layouts::Website < WidgetManager::Layout

  attr_accessor :ext_content, :ext_content_header, :ext_title, :ext_description,
    :ext_main_image, :ext_related_items, :ext_kabtv_exist,
    :ext_title_left, :ext_title_middle, :ext_title_right

  def initialize(*args, &block)
    super
    @header_search = w_class('header').new(:view_mode => 'search')
    @header_top_links_ext = w_class('header').new(:view_mode => 'top_links_ext')
    @header_top_links_int = w_class('header').new(:view_mode => 'top_links_int')
    @header_top_languages = w_class('language_menu').new
    @header_bottom_links = w_class('header').new(:view_mode => 'bottom_links')
    @header_logo = w_class('header').new(:view_mode => 'logo')
    @header_copyright = w_class('header').new(:view_mode => 'copyright')
    @static_tree = w_class('tree').new(:view_mode => 'static_ltr')
    @dynamic_tree = w_class('tree').new(:view_mode => 'dynamic', :display_hidden => true)
    @breadcrumbs = w_class('breadcrumbs').new()
    @titles = w_class('breadcrumbs').new(:view_mode => 'titles')
    @meta_title = w_class('breadcrumbs').new(:view_mode => 'meta_title')
    @google_analytics = w_class('google_analytics').new
    @send_to_friend = w_class('send_to_friend').new
    @send_form = w_class('send_to_friend').new(:view_mode => 'form')
    @direct_link = w_class('shortcut').new
    @comments = w_class('comments').new
    @previous_comments = w_class('comments').new(:view_mode => 'previous')
    @newsletter = w_class('newsletter').new(:view_mode => 'sidebar')
    @sections = w_class('sections').new
    kabtv_resources
  end

  def render
    edit_class = presenter.node.can_edit? ? 'admin' : ''
    
    rawtext '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">'
    html("xmlns" => "http://www.w3.org/1999/xhtml", "xml:lang" => "en", "lang" => "en") {
      head {
        meta "http-equiv" => "content-type", "content" => "text/html;charset=utf-8"
        meta "http-equiv" => "Content-language", "content" => "utf8"
        title ext_meta_title
        meta(:name => 'description', :content => ext_description)

        if presenter.node.can_edit?
          stylesheet_link_tag 'reset-fonts-grids', 'base-min', 'common/reset.css',
          '../ext/resources/css/ext-all',
          'rusmain/common.css',
          'rusmain/homepage.css',
          'rusmain/page_admin',
          'rusmain/jquery.tabs.css',
          'rusmain/superfish.css',
          '../highslide/highslide',
          'lightbox',
          :cache => false
        else
          stylesheet_link_tag 'reset-fonts-grids', 'base-min', 'common/reset.css',
          'rusmain/common.css',
          'rusmain/homepage.css',
          'rusmain/superfish.css',
          'rusmain/jquery.tabs.css',
          '../highslide/highslide',
          'lightbox'
          #,
          #:cache => 'cache/website'
        end

        rawtext '<!--[if IE]>'
        stylesheet_link_tag 'rusmain/ie6'
        rawtext '<![endif]-->'

        javascript_include_tag 'flashembed.min.js', 'embed', 'jquery',
        'ui/ui.core.min.js', 'ui/jquery.color.js', 'ui/ui.tabs.min.js',
        'jquery.curvycorners.packed.js', 'jquery.browser.js',
        'jquery.media.js', 'jquery.metadata.js','jquery.form.js',
        '../highslide/highslide-full.packed.js', 'supersubs', 'superfish',
        'jquery.livequery.min.js', 'jq-helpers-ru'
        #       , :cache => "cache_content_page-#{@presenter.website_hrid}"
        if presenter.node.can_edit?
          javascript_include_tag '../ext/adapter/ext/ext-base', '../ext/ext-all', 'ext-helpers-ru',
          'ui/ui.sortable.min.js', 'ui/ui.draggable.min.js', 'ui/ui.droppable.min.js'
          language = @presenter.site_settings[:short_language]
          javascript {
            rawtext 'Ext.BLANK_IMAGE_URL="/ext/resources/images/default/s.gif";'
            rawtext 'var head = Ext.fly(document.getElementsByTagName("head")[0]);'
            rawtext 'Ext.DomHelper.append(head, {'
            rawtext 'tag:"script"'
            rawtext ',type:"text/javascript"'
            rawtext ",src:'/ext/source/locale/ext-lang-#{language}.js'"
            rawtext '});'
          }
        end
      }
      body(:class => edit_class) {
        div(:id => 'doc2', :class => 'yui-t7') { # Width 950 px, navigation 224px on left side
          header_class = show_dynamic_tree # for admins
          div(:id => 'hd'){ # Header
            show_header(header_class)
          }
          div(:id => 'bd'){
            div(:id => 'yui-main'){
              div(:class => 'yui-b'){ # Main part
                div(:class => 'yui-gc'){ # 66/33
                  div(:class => 'yui-u first'){ # content
                    show_content
                  }
                  div(:class => 'yui-u'){ # blogs
                    show_right_side
                  }
                }
              }
            }
            div(:class => 'yui-b left-side'){ # video_gallery, newsletter, updates, banner
              show_left_side
            }
          }
          div(:id => 'ft'){
            show_footer
          } unless ext_kabtv_exist
          display @google_analytics
        }
      }
    }
  end
  
  private
  
  def left_column_resources
    @site_updates ||= TreeNode.get_subtree(
      :parent => presenter.website_node.id,
      :resource_type_hrids => %W{video_gallery site_updates newsletter banner},
      :depth => 1,
      :placeholders => ['left']
    )
  end

  def middle_column_resources
    @tree_nodes_middle ||= TreeNode.get_subtree(
      :parent => tree_node.id,
      :resource_type_hrids => ['content_preview', 'title'],
      :depth => 1,
      :placeholders => ['middle-home'],
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
      :placeholders => ['kabtv-home'],
      :status => ['PUBLISHED', 'DRAFT']
    )
  end

  def show_dynamic_tree
    return '' unless presenter.node.can_edit?
    div(:id => 'command-panel'){
      display @dynamic_tree
      div(:class => 'clear')
    }
    'under-command-panel'
  end

  def show_header(header_class)
    div(:id => 'header', :class => header_class){
      display @header_logo
      display @header_search
      div(:id => 'links'){
        make_sortable(:selector => '#header .links_ext', :axis => 'x') {
          display @header_top_links_ext
        }
        make_sortable(:selector => '#header .links_int', :axis => 'x') {
          display @header_top_links_int
        }
      }
      display @header_top_languages
    }
    div(:id => 'nav-empty'){nbsp}
    div(:id => 'nav'){
      div(:class => 'left-ear')
      div(:class => 'right-ear')
      display @sections
    }
  end

  def show_footer
    make_sortable(:selector => '#footer .links', :axis => 'x') {
      display @header_bottom_links
    }
    display @header_copyright
  end

  def show_left_side
    div(:class => 'left-part') {
      display ext_title_left unless ext_title_left.nil?

      w_class('cms_actions').new(:tree_node => tree_node,
        :options => {:buttons => %W{ new_button },
          :resource_types => %W{ video_gallery site_updates newsletter banner},
          :button_text => _(:create_new_leftside_item),
          :new_text => _(:create_new_leftside_item),
          :has_url => false,
          :placeholder => 'left'}).render_to(self)

      show_content_resources(:resources => left_column_resources,
        :parent => :website,
        :placeholder => :left,
        :sortable => true,
        :force_mode => 'sidebar'
      )
      make_sortable(:selector => ".left-part") {
        left_column_resources
      }
    }
  end

  def show_right_side
    display ext_title_right unless ext_title_right.nil?

    #    It was decided not to put TV on homepage as the page gets overloaded
    #
    #    if kabtv_resources.empty?
    #      w_class('cms_actions').new(:tree_node => tree_node,
    #        :options => {:buttons => %W{ new_button },
    #          :resource_types => %W{ kabtv },
    #          :button_text => _(:create_new_tv_unit),
    #          :new_text => _(:new_tv_unit),
    #          :has_url => false,
    #          :placeholder => 'kabtv-home'}).render_to(self) if kabtv_resources.empty?
    #    else
    #      show_content_resources(:resources => kabtv_resources,
    #        :parent => :website,
    #        :placeholder => 'kabtv-home',
    #        :force_mode => 'homepage',
    #        :sortable => false
    #      )
    #    end
    
    div(:class => 'downloads container'){
      w_class('cms_actions').new(:tree_node => tree_node,
        :options => {:buttons => %W{ new_button },
          :resource_types => %W{ media_rss },
          :new_text => _(:new_download),
          :mode => 'inline',
          :button_text => _(:add_downloads),
          :has_url => false,
          :placeholder => 'lesson'}).render_to(self)
      h3(:class => 'box-header') {
        text _(:lessons_to_download)
      }
      div(:class => 'entries'){
        show_content_resources(:resources => kabbalah_media_resources,
          :parent => :website,
          :placeholder => :lesson,
          :force_mode => 'preview',
          :sortable => true
        )
      }
      make_sortable(:selector => ".downloads .entries", :direction => 'y') {
        kabbalah_media_resources
      }
    }

    div(:class => 'right-column'){
      w_class('cms_actions').new(:tree_node => tree_node,
        :options => {:buttons => %W{ new_button },
          :resource_types => %W{ rss },
          :button_text => _(:new_rss),
          :new_text => _(:add_new_rss),
          :has_url => false,
          :placeholder => 'right'}).render_to(self)

      show_content_resources(:resources => right_column_resources,
        :parent => :website,
        :placeholder => :right,
        :force_mode => 'preview',
        :sortable => true
      )
      make_sortable(:selector => ".right-column", :direction => 'y') {
        right_column_resources
      }
    }
  end

  def right_column_resources
    @tree_nodes_right ||= TreeNode.get_subtree(
      :parent => tree_node.id,
      :resource_type_hrids => ['rss'],
      :depth => 1,
      :placeholders => ['right'],
      :status => ['PUBLISHED', 'DRAFT']
    )
  end


  def show_content
    div(:class => 'content') {
      display ext_title_middle unless ext_title_middle.nil?

      w_class('cms_actions').new(:tree_node => @tree_node,
        :options => {:buttons => %W{ new_button },
          :resource_types => %W{content_preview title},
          :new_text => _(:add_preview),
          :button_text => _(:add_content_entry),
          :has_url => false, :placeholder => 'middle-home'}).render_to(self)

      show_content_resources(:resources => middle_column_resources,
        :parent => :website,
        :placeholder => :middle,
        :sortable => true)

      make_sortable(:selector => ".content") {
        middle_column_resources
      }
    }
  end

end 
