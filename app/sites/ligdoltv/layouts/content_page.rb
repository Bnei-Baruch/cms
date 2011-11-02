class Ligdoltv::Layouts::ContentPage < WidgetManager::Layout

  attr_accessor :ext_content, :ext_breadcrumbs, :ext_content_header, :ext_title, :ext_description,
    :ext_main_image, :ext_related_items, :ext_kabtv_exist,
    :ext_abc_up, :ext_abc_down, :ext_keywords

  def initialize(*args, &block)
    super

    site_config = $config_manager.site_settings(@presenter.website.hrid)

    @header_top_links = w_class('header').new(:view_mode => 'top_links')
    @header_bottom_links = w_class('header').new(:view_mode => 'bottom_links')
    @header_logo = w_class('header').new(:view_mode => 'logo')
    @header_copyright = w_class('header').new(:view_mode => 'copyright')
    @static_tree = w_class('tree').new(:view_mode => 'static')
    @dynamic_tree = w_class('tree').new(:view_mode => 'dynamic', :display_hidden => true)
    @meta_title = w_class('breadcrumbs').new(:view_mode => 'meta_title')
    @google_analytics = w_class('google_analytics').new
    @newsletter = w_class('newsletter').new(:view_mode => 'sidebar') if site_config[:newsletters][:use]
    @sitemap = w_class('sitemap').new  if site_config[:sitemap][:use]
    @send_to_friend = w_class('send_to_friend').new
    @direct_link = w_class('shortcut').new
    @subscription = w_class('header').new(:view_mode => 'subscription')
    @comments = w_class('comments').new
    @archive = w_class('archive').new
    @previous_comments = w_class('comments').new(:view_mode => 'previous')
    @share = w_class('share_this').new(:view_mode => 'hebrew')
    @languages = w_class('language_menu').new
  end

  def is_langing_page?
    false
  end

  def render
    if is_langing_page?
      render_langing_page
    else
      render_regular
    end
  end

  def render_head
    head {
      meta "http-equiv" => "content-type", "content" => "text/html;charset=utf-8"
      meta "http-equiv" => "Content-language", "content" => "utf8"
      meta(:name => 'node_id', :content => @tree_node.id)
      meta(:name => 'description', :content => ext_description)
      meta(:name => 'keywords', :content => ext_keywords)
      title @meta_title
      text ext_abc_up

      javascript_include_tag 'flowplayer-3.2.4.min.js', 'flashembed.min.js'
      javascript_include_tag 'embed', 'jquery',
      'ui/ui.core.min.js', 'ui/jquery.color.js', 'ui/ui.tabs.min.js',
      'jquery.curvycorners.packed.js', 'jquery.browser.js',
      'jquery.media.js', 'jquery.metadata.js', 'jquery.form.js',
      '../highslide/highslide-full.js', 'countdown',
      'jq-helpers-hb', 'jquery.confirm-1.3.js' #,
      #:cache => "cache_content_page-#{@presenter.website_hrid}"

      javascript_include_tag 'wpaudioplayer/audio-player.js'

      stylesheet_link_tag 'reset-fonts-grids',
      'base-min',
      'hebmain/common',
      'hebmain/header',
      'hebmain/inner_page',
      'hebmain/jquery.tabs.css',
      'hebmain/widgets',
      '../highslide/highslide',
      'lightbox',
      :cache => "cache_content_page-#{@presenter.website_hrid}",
      :media => 'all'
      stylesheet_link_tag 'hebmain/print', :media => 'print'
      site_config = $config_manager.site_settings(@presenter.website.hrid)
      site_name = site_config[:site_name]
      stylesheet_link_tag "#{site_name}/#{site_name}"

      #        if presenter.node.can_edit?
      perm = AuthenticationModel.get_max_permission_to_child_tree_nodes_by_user_one_level(presenter.node.id)
      if  presenter.node.can_edit? || perm >= 2 # STUPID, but there are no constatns yet...!!!
        stylesheet_link_tag 'hebmain/page_admin', '../ext/resources/css/ext-all'
        javascript_include_tag '../ext/adapter/ext/ext-base', '../ext/ext-all', 'ext-helpers',
        'ui/ui.sortable.min.js', 'ui/ui.draggable.min.js', 'ui/ui.droppable.min.js',
        :cache => "cache_content_page_admin-#{@presenter.website_hrid}"
        javascript {
          rawtext 'Ext.BLANK_IMAGE_URL="/ext/resources/images/default/s.gif";'
          rawtext 'Ext.onReady(function(){Ext.QuickTips.init()});'
        }
      end

      rawtext "\n<!--[if IE 6]>\n"
      stylesheet_link_tag 'hebmain/ie6', :media => 'all'
      stylesheet_link_tag 'hebmain/ie6_print', :media => 'print'
      rawtext "\n<![endif]-->\n"

      rawtext "\n<!--[if IE 7]>\n"
      stylesheet_link_tag 'hebmain/ie6', :media => 'all'
      stylesheet_link_tag 'hebmain/ie7', :media => 'all'
      rawtext "\n<![endif]-->\n"

      rawtext "\n<!--[if IE 8]>\n"
      stylesheet_link_tag 'hebmain/ie8', :media => 'all'
      rawtext "\n<![endif]-->\n"

      if site_config[:googleAdd][:use]
        rawtext <<-GCA
            <script type="text/javascript" src="http://partner.googleadservices.com/gampad/google_service.js"></script>
            <script type="text/javascript">
                    GS_googleAddAdSenseService(#{site_config[:googleAdd][:googleAddAdSenseService]});
                    GS_googleEnableAllServices();
            </script>
            <script type="text/javascript">
                    GA_googleAddSlot("#{site_config[:googleAdd][:googleAddAdSenseService]}", "#{site_config[:googleAdd][:slot]}");
            </script>
            <script type="text/javascript">
                    GA_googleFetchAds();
            </script>
        GCA
      end
    }
    rawtext @styles if @styles
  end

  def render_langing_page
    site_config = $config_manager.site_settings(@presenter.website.hrid)

    @styles = "
      <style>
        #bd {background:0 none;}
      </style>
    ";
    rawtext '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">'
    html("xmlns" => "http://www.w3.org/1999/xhtml", "xml:lang" => "en", "lang" => "en") {
      render_head
      div(:id => 'doc', :class => 'yui-t7') {
        div(:id => 'bd') {
          if site_config[:googleAdd][:use]
            rawtext <<-GCA
              <script type="text/javascript">
                GA_googleFillSlot("#{site_config[:googleAdd][:slot]}");
              </script>
            GCA
          end
          div(:class => 'yui-g') {
            div(:class => 'content') {
              make_sortable(:selector => ".content", :axis => 'y') {
                self.ext_content.render_to(self)
              }
            }
          }
        }
      }
    }
  end

  def render_regular
    site_config = $config_manager.site_settings(@presenter.website.hrid)
    rawtext '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">'
    html("xmlns" => "http://www.w3.org/1999/xhtml", "xml:lang" => "en", "lang" => "en", :id => "#{site_config[:site_name]}") {
      render_head
      body {
        div(:id => 'doc2', :class => 'yui-t4') {
          div(:id => 'bd') {
            if site_config[:googleAdd][:use]
              div(:id => 'google_ads') {
                rawtext <<-GCA
              <script type="text/javascript">
                GA_googleFillSlot("kab-co-il_top-banner_950x65");
              </script>
                GCA
              }
            end
            if site_config[:single_logo][:use]
              div(:id => 'header') {
                make_sortable(:selector => '#hd .links', :axis => 'x') {
                  @header_top_links.render_to(self)
                }
              }
            end
            div(:id => 'yui-main') {
              div(:class => 'yui-b') {
                div(:class => 'yui-ge') {
                  @dynamic_tree.render_to(self)
                  unless site_config[:single_logo][:use]
                    div(:id => 'hd') {
                      make_sortable(:selector => '#hd .links', :axis => 'x') {
                        @header_top_links.render_to(self)
                      }
                    }
                  end
                  div(:class => 'menu') {
                    w_class('sections').new.render_to(self)
                  }
                  div(:class => 'margin-25') { text ' ' }
                  self.ext_breadcrumbs.render_to(self)
                  div(:class => 'content-header') {
                    make_sortable(:selector => ".content-header", :axis => 'y') {
                      self.ext_content_header.render_to(self)
                    }
                  }
                  div(:class => 'yui-u first') {
                    div(:class => 'content') {
                      make_sortable(:selector => ".content", :axis => 'y') {
                        self.ext_content.render_to(self)
                      }
                      @subscription.render_to(self)
                      div(:class => 'clear')

                      @share.render_to(self)
                      @comments.render_to(self)
                      @send_to_friend.render_to(self)
                      @direct_link.render_to(self)
                      @archive.render_to(self) if archived_resources.size > 0 && !@presenter.page_params.has_key?('archive')
                      @previous_comments.render_to(self)
                    }
                  }
                  div(:class => 'yui-u') {
                    div(:class => 'related') {
                      self.ext_main_image.render_to(self)
                      make_sortable(:selector => ".related", :axis => 'y') {
                        self.ext_related_items.render_to(self)
                      }
                    }
                  }
                }
              }
            }
            div(:class => 'yui-b') {
              unless site_config[:single_logo][:use]
                div(:id => 'hd-r') {
                  @header_logo.render_to(self)
                  @languages.render_to(self)
                } #Logo goes here
              end
              div(:class => 'nav') {
                div(:class => 'h1') {
                  text presenter.main_section.resource.name if presenter.main_section
                  div(:class =>'h1-right')
                  div(:class =>'h1-left')
                }
                @static_tree.render_to(self)
              }

              @newsletter.render_to(self)  if site_config[:newsletters][:use]

              global_site_updates.each { |e|
                render_content_resource(e)
              }
            }
          }

          div(:id => 'ft') {
            if site_config[:sitemap][:use]
              @sitemap.render_to(self) unless ext_kabtv_exist
            end
            make_sortable(:selector => '#ft .links', :axis => 'x') {
              @header_bottom_links.render_to(self)
            }
            @header_copyright.render_to(self)
          }
        }
        text ext_abc_down
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
      :resource_type_hrids => ['site_updates', 'banner'],
      :depth => 1,
      :placeholders => ['right']
    )
  end

  def archived_resources
    @archived_resources ||= TreeNode.get_subtree(
      :parent => tree_node.id,
      :resource_type_hrids => ['content_page'],
      :depth => 1,
      :has_url => true,
      :status => ['ARCHIVED']
    )
  end
end 
