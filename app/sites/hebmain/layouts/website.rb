class Hebmain::Layouts::Website < WidgetManager::Layout

  attr_accessor :ext_meta_title, :ext_meta_description

  def initialize(*args, &block)
    super
    @header_top_links = w_class('header').new(:view_mode => 'top_links')
    @header_bottom_links = w_class('header').new(:view_mode => 'bottom_links')
    @header_logo = w_class('header').new(:view_mode => 'logo')
    @breadcrumbs = w_class('breadcrumbs').new()
    @titles = w_class('breadcrumbs').new(:view_mode => 'titles')  
    @dynamic_tree = w_class('tree').new(:view_mode => 'dynamic', :display_hidden => true)
    @google_analytics = w_class('google_analytics').new
  end

  def render
    rawtext '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">'
    html("xmlns" => "http://www.w3.org/1999/xhtml", "xml:lang" => "en", "lang" => "en") {
      head {
        meta "http-equiv" => "content-type", "content" => "text/html;charset=utf-8"
        meta "http-equiv" => "Content-language", "content" => "utf8"
        title ext_meta_title
        meta(:name => 'description', :content => ext_meta_description)
        if presenter.node.can_edit?
          stylesheet_link_tag 'reset-fonts-grids', 
          'base-min', 
          '../ext/resources/css/ext-all', 
          'hebmain/common',
          'hebmain/header', 
          'hebmain/home_page', 
          'hebmain/page_admin',
          'hebmain/widgets',
          :cache => false
          # :cache => 'cache/website_admin'
          javascript_include_tag '../ext/adapter/ext/ext-base', '../ext/ext-all', 'ext-helpers'
          javascript {
            rawtext 'Ext.BLANK_IMAGE_URL="/ext/resources/images/default/s.gif";'
          }
        else
          stylesheet_link_tag 'reset-fonts-grids', 
          'base-min', 
          'hebmain/common',
          'hebmain/header', 
          'hebmain/home_page', 
          'hebmain/widgets',
          'hebmain/jquery.tabs.css',
          :cache => 'cache/website'
        end
        javascript_include_tag 'flashembed', 'jquery', 'jquery-ui', 'jq-helpers', :cache => 'cache/website'
      }
      body {
        div(:id => 'doc2', :class => 'yui-t5') {
          div(:id => 'bd') {
            div(:id => 'yui-main') {
              div(:class => 'yui-b') {
                div(:class => 'yui-gd') {
                  @dynamic_tree.render_to(doc)
                  div(:id => 'hd') { @header_top_links.render_to(self) } #Header goes here
                  div(:class => 'menu') {
                    w_class('sections').new.render_to(self)
                  }    
                  div(:class => 'yui-u first') {
                    div(:class => 'left-part') {
                      div(:class => 'h1') {
                        text 'קבלה Live'
                        div(:class =>'h1-right')
                        div(:class =>'h1-left')
                      }
                      w_class('cms_actions').new(:tree_node => tree_node, 
                        :options => {:buttons => %W{ new_button }, 
                          :resource_types => %W{ rss },
                          :button_text => 'הוספת יחידות תוכן - עמודה שמאלית',
                          :new_text => 'הוסף RSS נוסף',
                          :has_url => false, 
                          :placeholder => 'left'}).render_to(self)
              
                      
                      div(:id => 'radio-TV', :class => 'radio-TV') {
                        ul(:class => 'ui-tabs-nav'){
                          li{
                            a(:href => '#radio'){
                              span 'רדיו'
                            }
                          }
                          li{
                            a(:href => '#tv'){
                              span 'טלויזיה'
                            }
                          }
                        }
                      }
                      div(:id => 'tv'){
                        div(:class => 'tv-border'){
                          javascript {
                            rawtext <<-TV
                              if (jQuery.browser.msie) {
                                document.write('<object id="tvplayer" type="application/x-ms-wmp" height="140" standby="Loading Windows Media Player components..." width="194" classid="clsid:6BF52A52-394A-11D3-B153-00C04F79FAA6"><param name="AutoStart" value="0" /><param value="0" name="balance" /><param name="currentPosition" value="0"><param name="currentMarker" value="0"><param name="enabled" value="true"><param name="mute" value="false"><param name="playCount" value="1"><param name="rate" value="1"><param name="uiMode" value="none"><param name="volume" value="50"><param value="http://switch3.castup.net/cunet/gm.asp?ClipMediaID=160788" name="URL" /><param value="false" name="AutoPlay" /><param value="1" name="animationAtStart" /><param value="1" name="showDisplay" /><param value="0" name="transparentAtStart" /><param value="1" name="ShowControls" /><param value="1" name="ShowStatusBar" /><param value="1" name="ClickToPlay" /><param value="#000000" name="bgcolor" /><param value="1" name="windowlessVideo" /></object>');
                              } else {
                                document.write('<object id="tvplayer" type="application/x-ms-wmp" height="140" standby="Loading Windows Media Player components..." width="200"><param name="AutoStart" value="0" /><param value="0" name="balance" /><param name="currentPosition" value="0"><param name="currentMarker" value="0"><param name="enabled" value="true"><param name="mute" value="false"><param name="playCount" value="1"><param name="rate" value="1"><param name="uiMode" value="none"><param name="volume" value="50"><param value="http://switch3.castup.net/cunet/gm.asp?ClipMediaID=160788" name="URL" /><param value="0" name="AutoPlay" /><param value="1" name="animationAtStart" /><param value="1" name="showDisplay" /><param value="0" name="transparentAtStart" /><param value="1" name="ShowControls" /><param value="1" name="ShowStatusBar" /><param value="1" name="ClickToPlay" /><param value="#000000" name="bgcolor" /><param value="1" name="windowlessVideo" /><p>Error - the plugin has not loaded<br/><a href="http://port25.technet.com/pages/windows-media-player-firefox-plugin-download.aspx">Download Microsoft plugin for Firefox here</a></p>');
                                document.write('<embed width="200" height="140" balance="0" uimode="none" autostart="false" pluginspage="http://activex.microsoft.com/activex/controls/mplayer/en/nsmp2inf.cab#Version=6,4,7,1112" type="application/x-mplayer2" src="http://switch3.castup.net/cunet/gm.asp?ClipMediaID=160788" name="tvplayer" id="tvplayer"/>');
                                document.write('</object>');
                              }
                            TV
                          }
                          div(:class => 'tv') {
  #                          img(:src => img_path('radio/bg.jpg'), :alt => '')
  #                          div(:class => 'text') {text 'ווידאו קבלה' }
                            div(:class => 'play play-in')
                            div(:class => 'stop stop-out')
                            a(:class => 'right', :id => 'full_screen', :href => '') {rawtext _('למסך מלא')}
                            div(:class => 'clear'){rawtext '&nbsp'}
                          }
                        }
                      }
                      div(:id => 'radio'){
                        div(:class => 'radio') {
                          img(:src => img_path('radio/bg.jpg'), :alt => '')
                          div(:class => 'text') {text 'רדיו קבלה FM' }
                          div(:class => 'play play-out')
                          div(:class => 'stop stop-out')
                        }
                        javascript {
                          rawtext <<-RADIO
                              if (jQuery.browser.msie) {
document.write('<object id="radioplayer" style="display:none" classid="clsid:6BF52A52-394A-11D3-B153-00C04F79FAA6" style="display:inline;background-color:#000000;" id="tvplayer" type="application/x-oleobject" width="222" height="40" standby="Loading Windows Media Player components..."> <param name="URL" value="mms://vod.kab.tv/radioheb" /> <param name="AutoStart" value="0" /><param name="AutoPlay" value="0" /><param name="volume" value="50" /> <param name="uiMode" value="invisible" /><param name="animationAtStart" value="0" /> <param name="showDisplay" value="0" /><param name="transparentAtStart" value="0" /> <param name="ShowControls" value="0" /><param name="ShowStatusBar" value="0" /> <param name="ClickToPlay" value="0" /><param name="bgcolor" value="#000000" /> <param name="windowlessVideo" value="0" /><param name="balance" value="0" /> </object>');
                              } else {
document.write('<embed id="radioplayer" src="mms://vod.kab.tv/radioheb" type="application/x-mplayer2" pluginspage="http://activex.microsoft.com/activex/controls/mplayer/en/nsmp2inf.cab#Version=6,4,7,1112" autostart="false" uimode="full" width="222" height="40" />');
                              }
                          RADIO
                        }
                      }
                      
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
                              :placeholder => 'left'}).render_to(self)
                        }
                        div(:class => 'entries'){
                          kabbalah_media_resources.each { |kabbalah_media_resource|                
                            render_content_resource(kabbalah_media_resource)
                          } 
                        }
                      }
                      
                      left_column_resources.each { |left_column_resource|                
                        render_content_resource(left_column_resource,
                          left_column_resource.resource.resource_type.hrid == 'rss' ? 'preview' : 'full')
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
                          :resource_types => %W{content_preview},
                          :new_text => 'הוסף תצוגה מקדימה',
                          :button_text => 'הוספת יחידות תוכן - עמודה מרכזית',
                          :has_url => false, :placeholder => 'middle'}).render_to(self)
                      
                      middle_column_resources.each { |middle_column_resource|
                        render_content_resource(middle_column_resource)
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
                
                right_column_resources.each { |right_column_resource|
                  render_content_resource(right_column_resource)
                }                
              }
            }
          }
          div(:id => 'ft') {
            @header_bottom_links.render_to(self)
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
      :placeholders => ['right']
    ) 
  end
  
  def left_column_resources
    @tree_nodes_left ||= TreeNode.get_subtree(
      :parent => tree_node.id, 
      :resource_type_hrids => ['rss'], 
      :depth => 1,
      :placeholders => ['left']
    ) 
  end
  
  def middle_column_resources
    @tree_nodes_middle ||= TreeNode.get_subtree(
      :parent => tree_node.id, 
      :resource_type_hrids => ['content_preview'], 
      :depth => 1,
      :placeholders => ['middle']
    ) 
  end
  
  def kabbalah_media_resources
    @kabbalah_media_nodes ||= TreeNode.get_subtree(
      :parent => tree_node.id, 
      :resource_type_hrids => ['media_rss'], 
      :depth => 1,
      :placeholders => ['left']
    ) 
  end
end 
