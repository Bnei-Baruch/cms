class Hebmain::Layouts::Website < WidgetManager::Layout

  attr_accessor :ext_meta_title, :ext_meta_description

  def initialize(*args, &block)
    super
    @header_top_links = w_class('header').new(:view_mode => 'top_links')
    @header_bottom_links = w_class('header').new(:view_mode => 'bottom_links')
    @header_logo = w_class('header').new(:view_mode => 'logo')
    @header_copyright = w_class('header').new(:view_mode => 'copyright')
    @breadcrumbs = w_class('breadcrumbs').new()
    @titles = w_class('breadcrumbs').new(:view_mode => 'titles')  
    @dynamic_tree = w_class('tree').new(:view_mode => 'dynamic', :display_hidden => true)
    @google_analytics = w_class('google_analytics').new
    @newsletter = w_class('newsletter').new(:view_mode => 'sidebar')
  end

  def render
    rawtext '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">'
    html("xmlns" => "http://www.w3.org/1999/xhtml", "xml:lang" => "en", "lang" => "en") {
      head {
        meta "http-equiv" => "content-type", "content" => "text/html;charset=utf-8"
        meta "http-equiv" => "Content-language", "content" => "utf8"
        title ext_meta_title
        meta(:name => 'description', :content => ext_meta_description)

        javascript_include_tag 'jquery', 
        'ui/ui.core.min.js',
        'ui/jquery.color.js',
        'jquery.curvycorners.packed.js', 'jquery.browser.js', 'jq-helpers-hb',
        'flashembed.min.js', 'jquery.livequery.min.js',
        :cache => "cache_website-#{@presenter.website_hrid}"

        stylesheet_link_tag 'reset-fonts-grids',
        'base-min',
        'hebmain/common',
        'hebmain/header',
        'hebmain/home_page',
        'hebmain/widgets',
        :cache => "cache_website-#{@presenter.website_hrid}"

        if presenter.node.can_edit?
          stylesheet_link_tag '../ext/resources/css/ext-all', 'hebmain/page_admin'
          javascript_include_tag '../ext/adapter/ext/ext-base', '../ext/ext-all', 'ext-helpers',
          'ui/ui.sortable.min.js', 'ui/ui.draggable.min.js', 'ui/ui.droppable.min.js',
          :cache => "cache_website_admin-#{@presenter.website_hrid}"
          javascript {
            rawtext 'Ext.BLANK_IMAGE_URL="/ext/resources/images/default/s.gif";'
          }
        else
        end

        rawtext "\n<!--[if IE 6]>\n"
        stylesheet_link_tag 'hebmain/ie6', :media => 'all'
        rawtext "\n<![endif]-->\n"

        rawtext "\n<!--[if IE 7]>\n"
        stylesheet_link_tag 'hebmain/ie6', :media => 'all'
        stylesheet_link_tag 'hebmain/ie7', :media => 'all'
        rawtext "\n<![endif]-->\n"
      }
      body {
        div(:id => 'doc2', :class => 'yui-t5') {
          div(:id => 'bd') {
            div(:id => 'yui-main') {
              div(:class => 'yui-b') {
                div(:class => 'yui-gd') {
                  @dynamic_tree.render_to(self)
                  div(:id => 'hd') {
                    make_sortable(:selector => '#hd .links', :axis => 'x') {
                      @header_top_links.render_to(self)
                    }
                  }
                  div(:class => 'menu') {
                    w_class('sections').new.render_to(self)
                  }    
                  div(:class => 'yui-u first') {
                    div(:class => 'left-part') {
                      w_class('cms_actions').new(:tree_node => tree_node,
                        :options => {:buttons => %W{ new_button },
                          :resource_types => %W{ rss },
                          :button_text => 'הוספת יחידות תוכן - עמודה שמאלית',
                          :new_text => 'הוסף RSS נוסף',
                          :has_url => false,
                          :placeholder => 'left'}).render_to(self)
              
                      w_class('cms_actions').new(:tree_node => tree_node,
                        :options => {:buttons => %W{ new_button },
                          :resource_types => %W{ kabtv },
                          :button_text => 'ניהול יחידת טלוויזיה',
                          :new_text => 'הוספת יחידת טלוויזיה',
                          :has_url => false,
                          :placeholder => 'home_kabtv'}).render_to(self)
                      show_content_resources(:resources => kabtv_resources,
                        :parent => :website,
                        :placeholder => :home_kabtv,
                        :sortable => false
                      )
                      
                      div(:class => 'downloads container'){
                        h3(:class => 'box_header') {
                          text 'שיעורים להורדה'
                          w_class('cms_actions').new(:tree_node => tree_node, 
                            :options => {:buttons => %W{ new_button }, 
                              :resource_types => %W{ media_rss },
                              :new_text => 'צור יחידת תוכן חדשה',
                              :mode => 'inline',
                              :button_text => 'הוספת הורדות',
                              :has_url => false, 
                              :placeholder => 'lesson'}).render_to(self)
                        }
                        div(:class => 'entries'){
                          show_content_resources(:resources => kabbalah_media_resources,
                            :parent => :website,
                            :placeholder => :left,
                            :sortable => true
                          )
                        }
                        make_sortable(:selector => ".downloads .entries", :axis => 'y') {
                          kabbalah_media_resources
                        }
                      }
                      
                      div(:class => 'left-column'){
                        show_content_resources(:resources => left_column_resources,
                          :parent => :website,
                          :placeholder => :left,
                          :sortable => true
                        )
                      }
                      make_sortable(:selector => ".left-column") {
                        left_column_resources
                      }
                    }
                  }
                  div(:class => 'yui-u') {
                    div(:class => 'content') {
                      div(:class => 'h1') {
                        text 'המומלצים'
                        div(:class =>'h1-right')
                        div(:class =>'h1-left')
                      }

                      w_class('cms_actions').new(:tree_node => @tree_node,
                        :options => {:buttons => %W{ new_button },
                          :resource_types => %W{content_preview title},
                          :new_text => 'הוסף תצוגה מקדימה',
                          :button_text => 'הוספת יחידות תוכן - עמודה מרכזית',
                          :has_url => false, :placeholder => 'middle'}).render_to(self)

                      show_content_resources(:resources => middle_column_resources,
                        :parent => :website,
                        :placeholder => :middle,
                        :sortable => true)

                      make_sortable(:selector => ".content") {
                        middle_column_resources
                      }
                    }
                  }
                }
              }
            }
            div(:class => 'yui-b') {
              div(:id => 'hd-r') { @header_logo.render_to(self) } #Logo goes here
              div(:class => 'right-part') {
                div(:class => 'h1') {
                  text 'קבלה למתחיל'
                  div(:class =>'h1-right')
                  div(:class =>'h1-left')
                }
                w_class('cms_actions').new(:tree_node => tree_node, 
                  :options => {:buttons => %W{ new_button }, 
                    :resource_types => %W{ video_gallery site_updates },
                    :new_text => 'צור יחידת תוכן חדשה', 
                    :has_url => false, 
                    :placeholder => 'right'}).render_to(self)
            	
                show_content_resources(:resources => right_column_resources,
                  :parent => :website,
                  :placeholder => :right,
                  :sortable => true) { |idx|
                  @newsletter.render_to(self) if (idx == 1)
                }
                make_sortable(:selector => ".right-part") {
                  right_column_resources
                }
              }
            }
          }
          div(:id => 'ft') {
            make_sortable(:selector => '#ft .links', :axis => 'x') {
              @header_bottom_links.render_to(self)
            }
            @header_copyright.render_to(self)
          }
        }
        @google_analytics.render_to(self)
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
