class Ligdoltv::Layouts::Website < WidgetManager::Layout

  attr_accessor :ext_meta_title, :ext_meta_description

  def initialize(*args, &block)
    super

    @site_config = $config_manager.site_settings(@presenter.website.hrid)

    @header_top_links = w_class('header').new(:view_mode => 'top_links')
    @header_bottom_links = w_class('header').new(:view_mode => 'bottom_links')
    @header_logo = w_class('header').new(:view_mode => 'logo')
    @header_copyright = w_class('header').new(:view_mode => 'copyright')
    @breadcrumbs = w_class('breadcrumbs').new()
    @titles = w_class('breadcrumbs').new(:view_mode => 'titles')
    @dynamic_tree = w_class('tree').new(:view_mode => 'dynamic', :display_hidden => true)
    @google_analytics = w_class('google_analytics').new
    @newsletter = w_class('newsletter').new(:view_mode => 'sidebar') if @site_config[:newsletters][:use]
    @languages = w_class('language_menu').new
  end

  def render

    rawtext '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">'
    html("xmlns" => "http://www.w3.org/1999/xhtml", "xml:lang" => "en", "lang" => "en", :id => "#{@site_config[:site_name]}") {
      head {
        meta "http-equiv" => "content-type", "content" => "text/html;charset=utf-8"
        meta "http-equiv" => "Content-language", "content" => "utf8"
        link(:rel => 'shortcut icon', :href => 'http://www.ligdoltv.co.il/favicon-ligdoltv.ico')
        title ext_meta_title
        meta(:name => 'description', :content => ext_meta_description)

        javascript_include_tag 'flowplayer-3.2.4.min.js', 'flashembed.min.js'
        javascript_include_tag 'jquery',
                               'ui/ui.core.min.js',
                               'ui/jquery.color.js',
                               'jquery.browser.js', 'jq-helpers-hb',
                               :cache => "cache_website-#{@presenter.website_hrid}"

        stylesheet_link_tag 'reset-fonts-grids',
                            'base-min',
                            'hebmain/common',
                            'hebmain/header',
                            'hebmain/home_page',
                            'hebmain/widgets',
                            :cache => "cache_website-#{@presenter.website_hrid}"

        site_name = @site_config[:site_name]
        stylesheet_link_tag "#{site_name}/#{site_name}"

        #        if presenter.node.can_edit?
        perm = AuthenticationModel.get_max_permission_to_child_tree_nodes_by_user_one_level(presenter.node.id)
        if  presenter.node.can_edit? || perm >= 2 # STUPID, but there are no constatns yet...!!!
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

        if @site_config[:googleAdd][:use]
          rawtext <<-GCA
            <script type="text/javascript" src="http://partner.googleadservices.com/gampad/google_service.js"></script>
            <script type="text/javascript">
              GS_googleAddAdSenseService("#{site_config[:googleAdd][:googleAddAdSenseService]}");
              GS_googleEnableAllServices();
            </script>
            <script type="text/javascript">
              GA_googleAddSlot("ca-pub-9068547212525872", "kab-co-il_top-banner_950x65");
            </script>
            <script type="text/javascript">
              GA_googleFetchAds();
            </script>
          GCA
        end
      }
      body {
        div(:id => 'doc2', :class => 'yui-t5') {
          div(:id => 'bd') {
            div(:id => 'google_ads') {
              if @site_config[:googleAdd][:use]
                rawtext <<-GCA
                <script type="text/javascript">
                  GA_googleFillSlot("kab-co-il_top-banner_950x65");
                </script>
                GCA
              end
            }
            if @site_config[:single_logo][:use]
              div(:id => 'header') {
                make_sortable(:selector => '#hd .links', :axis => 'x') {
                  @header_top_links.render_to(self)
                }
              }
            end
            div(:id => 'yui-main') {
              div(:class => 'yui-b') {
                div(:class => 'yui-gd') {
                  @dynamic_tree.render_to(self)
                  unless @site_config[:single_logo][:use]
                    div(:id => 'hd') {
                      make_sortable(:selector => '#hd .links', :axis => 'x') {
                        @header_top_links.render_to(self)
                      }
                    }
                  end
                  div(:class => 'menu') {
                    w_class('sections').new.render_to(self)
                  }
                  div(:class => 'yui-u first') {
                    div(:class => 'left-part') {
                      # streamer (hardcoded)
                      div(:class => 'h1') {
                        text ''
                        div(:class => 'h1-right')
                        div(:class => 'h1-left')
                      }

                      #render_hardcoded_streamer('http://switch3.castup.net/cunet/gm.asp?ClipMediaID=160788', 199, 214)
                      #render_hardcoded_streamer('mms://vod.kab.tv/ligdoltv', 199, 214)

                      w_class('cms_actions').new(:tree_node => tree_node,
                                                 :options => {:buttons => %W{ new_button },
                                                              :resource_types => %W{ rss },
                                                              :button_text => 'הוספת יחידות תוכן - עמודה שמ�?לית',
                                                              :new_text => 'הוסף RSS נוסף',
                                                              :has_url => false,
                                                              :placeholder => 'left'}).render_to(self)

                      w_class('cms_actions').new(:tree_node => tree_node,
                                                 :options => {:buttons => %W{ new_button },
                                                              :resource_types => %W{ iframe },
                                                              :button_text => 'הוספת יחידות iframe - עמודה שמ�?לית',
                                                              :new_text => 'הוסף iframe נוסף',
                                                              :has_url => false,
                                                              :placeholder => 'left'}).render_to(self)

                      w_class('cms_actions').new(:tree_node => tree_node,
                                                 :options => {:buttons => %W{ new_button },
                                                              :resource_types => %W{ kabtv },
                                                              :button_text => 'ניהול יחידת טלוויזיה',
                                                              :new_text => 'הוספת יחידת טלוויזיה',
                                                              :has_url => false,
                                                              :placeholder => 'home_kabtv'}).render_to(self)

                      #                      w_class('cms_actions').new(:tree_node => tree_node,
                      #                        :options => {:buttons => %W{ new_button },
                      #                          :resource_types => %W{ streamer },
                      #                          :button_text => 'streamer',
                      #                          :new_text => 'add new streamer',
                      #                          :has_url => false,
                      #                          :placeholder => 'left'}).render_to(self)

                      #show_content_resources(:resources => kabtv_resources,
                      #:parent => :website,
                      #:placeholder => :home_kabtv,
                      #:sortable => false
                      #)

                      div(:class => 'left-column') {
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
                        text 'המומלצי�?'
                        div(:class => 'h1-right')
                        div(:class => 'h1-left')
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
              unless @site_config[:single_logo][:use]
                div(:id => 'hd-r') {
                  @header_logo.render_to(self)
                  @languages.render_to(self)

                } #Logo goes here
              end
              div(:class => 'right-part') {
                div(:class => 'h1') {
                  text 'הקליפ היומי'
                  div(:class => 'h1-right')
                  div(:class => 'h1-left')
                }
                begin
                  video_gallery

                  downloads

                  right_column
                rescue Exception => e
                  Logger.new(STDOUT).error e.message
                  Logger.new(STDOUT).error e.backtrace.join('\n')
                end
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
        :resource_type_hrids => ['site_updates', 'newsletter', 'banner'],
        :depth => 1,
        :placeholders => ['right'],
        :status => ['PUBLISHED', 'DRAFT']
    )
  end

  def right_column_video_gallery_resources
    @tree_nodes_right_video_gallery ||= TreeNode.get_subtree(
        :parent => tree_node.id,
        :resource_type_hrids => ['video_gallery'],
        :depth => 1,
        :placeholders => ['right'],
        :status => ['PUBLISHED', 'DRAFT']
    )
  end

  def left_column_resources
    @tree_nodes_left ||= TreeNode.get_subtree(
        :parent => tree_node.id,
        :resource_type_hrids => ['rss', 'iframe'],
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

  def downloads
    return
    div(:class => 'downloads container') {
      h3(:class => 'box_header') {
        text 'שיעור הקבלה היומי להורדה'
        w_class('cms_actions').new(:tree_node => tree_node,
                                   :options => {:buttons => %W{ new_button },
                                                :resource_types => %W{ media_rss },
                                                :new_text => 'צור יחידת תוכן חדשה',
                                                :mode => 'inline',
                                                :button_text => 'הוספת הורדות',
                                                :has_url => false,
                                                :placeholder => 'lesson'}).render_to(self)
      }
      div(:class => 'entries') {
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
  end

  def video_gallery
    w_class('cms_actions').new(:tree_node => tree_node,
                               :options => {:buttons => %W{ new_button },
                                            :resource_types => %W{ video_gallery },
                                            :new_text => 'צור יחידת תוכן חדשה',
                                            :has_url => false,
                                            :placeholder => 'right'}).render_to(self)

    show_content_resources(:resources => right_column_video_gallery_resources,
                           :parent => :website,
                           :placeholder => :right,
                           :sortable => true) { |idx|
      @newsletter.render_to(self) if (idx == 1)
    }
  end

  def right_column
    w_class('cms_actions').new(:tree_node => tree_node,
                               :options => {:buttons => %W{ new_button },
                                            :resource_types => %W{ site_updates newsletter banner},
                                            :new_text => 'צור יחידת תוכן חדשה',
                                            :has_url => false,
                                            :placeholder => 'right'}).render_to(self)

    div(:class => 'right-part') {
      show_content_resources(:resources => right_column_resources,
                             :parent => :website,
                             :placeholder => :right,
                             :sortable => true) { |idx|
        @newsletter.render_to(self) if (idx == 0 && @newsletter)
      }
    }
    make_sortable(:selector => ".right-part") {
      right_column_resources
    }
  end

  def render_hardcoded_streamer(url, width, height)
    rawtext <<-STREAM
			<div id="stream" style="text-align: center; margin-bottom: 10px; background: #F0F4FD; padding: 5px;">
			<div id="tvobj">
			<!--[If IE]>
			<object
				classid="clsid:6BF52A52-394A-11D3-B153-00C04F79FAA6"
				type="application/x-oleobject"
				id="player"
				name="player"
				data="#{url}"
				width="#{width}"
				height="#{height}">
				<param name="url" value="#{url}" />
				<param name="autostart" value="true" />
				<param name="controller" value="true" />
				<param name="volume" value="50" />
				<param name="uiMode" value="mini" />
				<param name="mute" value="true" />
				<param name="animationAtStart" value="true" />
				<param name="showDisplay" value="false" />
				<param name="ShowAudioControls" value="true" />
				<param name="ShowPositionControls" value="false" />
				<param name="transparentAtStart" value="false" / >
				<param name="ShowControls" value="true" />
				<param name="ShowStatusBar" value="true" />
				<param name="ShowTracker" value="false" />
				<param name="ClickToPlay" value="false" />
				<param name="DisplayBackColor" value="#000000" />
				<param name="DisplayForeColor" value="#ffffff" />
				<param name="balance" value="false" />
			</object>
			<![endif]-->
			<!--[if !IE]>-->
			<object
				type="application/x-oleobject"
				classid="CLSID:22D6F312-B0F6-11D0-94AB-0080C74C7E95"
				id="player"
				name="player"
				data="#{url}"
				width="#{width}"
				height="#{height}">
				<param name="src" value="#{url}" />
				<param name="autostart" value="true" />
				<param name="controller" value="true" />
				<param name="volume" value="50" />
				<param name="uiMode" value="mini" />
				<param name="mute" value="true" />
				<param name="animationAtStart" value="true" />
				<param name="showDisplay" value="false" />
				<param name="ShowAudioControls" value="true" />
				<param name="ShowPositionControls" value="false" />
				<param name="transparentAtStart" value="false" />
				<param name="ShowControls" value="true" />
				<param name="ShowStatusBar" value="true" />
				<param name="ShowTracker" value="false" />
				<param name="ClickToPlay" value="false" />
				<param name="DisplayBackColor" value="#000000" />
				<param name="DisplayForeColor" value="#ffffff" />
				<param name="balance" value="false" />
        <embed type="application/x-mplayer2" pluginspage="http://www.microsoft.com/Windows/MediaPlayer/"
          src="#{url}"
          width="#{width}"
          height="#{height}"
          showcontrols=1 mute=1
          showstatusbar=1>
        </embed>

			</object>
			<!--<![endif]-->
			</div>
			</div>

    STREAM
  end
end 
