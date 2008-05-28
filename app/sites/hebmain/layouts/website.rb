class Hebmain::Layouts::Website < WidgetManager::Layout

  attr_accessor :ext_content, :ext_title, :ext_main_image, :ext_related_items

  def initialize(*args, &block)
    super
    @header_top_links = w_class('header').new(:view_mode => 'top_links')
    @header_bottom_links = w_class('header').new(:view_mode => 'bottom_links')
    @header_logo = w_class('header').new(:view_mode => 'logo')
    @breadcrumbs = w_class('breadcrumbs').new()
    @titles = w_class('breadcrumbs').new(:view_mode => 'titles')  
    @dynamic_tree = w_class('tree').new(:view_mode => 'dynamic', :display_hidden => true)
  end

  def render
    rawtext '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">'
    html("xmlns" => "http://www.w3.org/1999/xhtml", "xml:lang" => "en", "lang" => "en") {
      head {
        meta "http-equiv" => "content-type", "content" => "text/html;charset=utf-8"
        meta "http-equiv" => "Content-language", "content" => "utf8"
        title ext_title
        if @presenter.node.can_edit?
          stylesheet_link_tag 'reset-fonts-grids', 
          'base-min', 
          '../ext/resources/css/ext-all', 
          'hebmain/header', 
          'hebmain/home_page', 
          'hebmain/page_admin',
          :cache => 'website_admin'
        else
          stylesheet_link_tag 'reset-fonts-grids', 
          'base-min', 
          '../ext/resources/css/ext-all', 
          'hebmain/header', 
          'hebmain/home_page', 
          :cache => 'website'
        end
        # css get_css_url('header')
        # css get_css_url('home_page')
        # css get_css_url('page_admin')
        javascript_include_tag 'flashembed', '../ext/adapter/ext/ext-base', '../ext/ext-all', 'ext-helpers', :cache => 'website'
        javascript {
          rawtext 'Ext.util.CSS.swapStyleSheet("theme","ext/resources/css/xtheme-gray.css");'
          rawtext 'Ext.BLANK_IMAGE_URL="/ext/resources/images/default/s.gif";'
          rawtext 'Ext.onReady(function(){Ext.QuickTips.init()});'
        }
        javascript{
          rawtext <<-TV
            function startPlayer(id){
              var player = document.getElementById(id);
              if (player && player.controls && player.controls.isAvailable('Play')){
                player.controls.play();
              }
            };
            function pausePlayer(id){
              var player = document.getElementById(id);
              if (player && player.controls && player.controls.isAvailable('Pause')) {
                player.controls.pause();
              }
            }
            function stopPlayer(id){
              var player = document.getElementById(id);
              if (player && player.controls && player.controls.isAvailable('Stop')) {
                player.controls.stop();
              }
            }
            Ext.onReady(function() {
              var play = Ext.select('.radio .play');
              var playState = false;
              play.on('click', function(){
                if (!playState) {
                  startPlayer('radioplayer');
                  playState = true;
                }
              });
              play.on('mouseover', function(e){
                if (!playState)
                  Ext.get(this).replaceClass('play-out', 'play-in');
              });
              play.on('mouseout', function(){
                if (!playState)
                  Ext.get(this).replaceClass('play-in', 'play-out');
              });
              var stop = Ext.select('.radio .stop');
              stop.on('click', function(){
                if (playState) {
                  stopPlayer('radioplayer');
                  playState = false;
                  Ext.get(play).replaceClass('play-in', 'play-out');
                }
              });
              stop.on('mouseover', function(){
                Ext.get(this).replaceClass('stop-out', 'stop-in');
              });
              stop.on('mouseout', function(){
                Ext.get(this).replaceClass('stop-in', 'stop-out');
              });
              var mytab = new Ext.TabPanel({
                resizeTabs:true,
                renderTo: 'tabs1',
                width:222,
                activeTab:0,
                deferredRender:false,
                frame:true,
                items:[
                    {contentEl:'radio', title: 'רדיו' },
                    {contentEl:'tv', title: 'טלויזיה' }
                ]
              });
              mytab.on('tabchange', function(panel, tab){
                if (tab.contentEl == "tv"){
                  stopPlayer("radioplayer");
                  playState = false;
                  Ext.get(play).replaceClass('play-in', 'play-out');
                  startPlayer("tvplayer");
                } else {
                  stopPlayer("tvplayer");
                }
              });
            });
            function toggleUL(div){
              var el = Ext.get(div);
              var child = el.prev().first();
              if (el.isDisplayed()) {
                el.fadeOut({afterStyle:"display:none"});
                child.replaceClass("x-tree-elbow-minus","x-tree-elbow-plus");
              } else {
                el.fadeIn({});
                child.replaceClass("x-tree-elbow-plus","x-tree-elbow-minus");
              }
            }
           function mouseUL(div, direction){
            var el = Ext.get(div).prev();
            if (direction) {
              el.addClass("x-tree-ec-over");
            } else {
              el.removeClass("x-tree-ec-over");
            }
          }
          TV
        }

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
                        text 'קבלה online'
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
              
                      div(:id => 'tabs1', :class => 'radio-TV') {
                        div(:id => 'tv', :class => 'x-hide-display body'){
                          javascript {
                            rawtext <<-TV
                            if (Ext.isIE) {
document.write('<object classid="clsid:6BF52A52-394A-11D3-B153-00C04F79FAA6" style="display:inline;background-color:#000000;" id="tvplayer" type="application/x-oleobject" width="200" height="150" standby="Loading Windows Media Player components..."><param name="URL" value="http://switch3.castup.net/cunet/gm.asp?ClipMediaID=160788" /><param name="AutoStart" value="0" /><param name="AutoPlay" value="0" /><param name="volume" value="50" /><param name="uiMode" value="full" /><param name="animationAtStart" value="1" /><param name="showDisplay" value="1" /><param name="transparentAtStart" value="0" /><param name="ShowControls" value="1" /><param name="ShowStatusBar" value="1" /><param name="ClickToPlay" value="0" /><param name="bgcolor" value="#000000" /><param name="windowlessVideo" value="1" /><param name="balance" value="0" /></object>');
                            } else {
document.write('<embed id="tvplayer" src="http://switch3.castup.net/cunet/gm.asp?ClipMediaID=160788" type="application/x-mplayer2" pluginspage="http://activex.microsoft.com/activex/controls/mplayer/en/nsmp2inf.cab#Version=6,4,7,1112" autostart="false" uimode="full" width="200" height="150" />');
                            }
                            TV
                          }
                          div(:class => 'clear'){
                            a _('Watch in full window'), :href => ''
                          }
                        }
                        div(:id => 'radio', :class => 'x-hide-display body'){
                          javascript {
                            rawtext <<-RADIO
                              if (Ext.isIE) {
document.write('<object id="radioplayer" style="display:none" classid="clsid:6BF52A52-394A-11D3-B153-00C04F79FAA6" style="display:inline;background-color:#000000;" id="tvplayer" type="application/x-oleobject" width="222" height="40" standby="Loading Windows Media Player components..."> <param name="URL" value="mms://vod.kab.tv/radioheb" /> <param name="AutoStart" value="0" /><param name="AutoPlay" value="0" /><param name="volume" value="50" /> <param name="uiMode" value="invisible" /><param name="animationAtStart" value="0" /> <param name="showDisplay" value="0" /><param name="transparentAtStart" value="0" /> <param name="ShowControls" value="0" /><param name="ShowStatusBar" value="0" /> <param name="ClickToPlay" value="0" /><param name="bgcolor" value="#000000" /> <param name="windowlessVideo" value="0" /><param name="balance" value="0" /> </object>');
                              } else {
document.write('<embed id="radioplayer" src="mms://vod.kab.tv/radioheb" type="application/x-mplayer2" pluginspage="http://activex.microsoft.com/activex/controls/mplayer/en/nsmp2inf.cab#Version=6,4,7,1112" autostart="false" uimode="full" width="222" height="40" />');
                              }
                            RADIO
                          }
                          div(:class => 'radio') {
                            img(:src => img_path('radio/bg.jpg'), :alt => '')
                            div(:class => 'text') {text 'רדיו קבלה FM' }
                            div(:class => 'play play-out')
                            div(:class => 'stop stop-out')
                          }
                        }
                      }
                      
                      div(:class => 'downloads'){
                        h3(:class => 'box_header') {
                          text 'הורדות חינם'
                          w_class('cms_actions').new(:tree_node => tree_node, 
                            :options => {:buttons => %W{ new_button }, 
                              :resource_types => %W{ media_rss },
                              :new_text => 'צור יחידת תוכן חדשה',
                              :mode => 'inline',
                              :button_text => 'הוספת הורדות',
                              :has_url => false, 
                              :placeholder => 'left'}).render_to(self)
                        }

                        kabbalah_media_resources.each { |kabbalah_media_resource|                
                          render_content_resource(kabbalah_media_resource)
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
                        text 'קבלה ללומד'
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
                  text 'מאיפה להתחיל?'
                  div(:class =>'h1-right')
                  div(:class =>'h1-left')
                }
                w_class('cms_actions').new(:tree_node => tree_node, 
                  :options => {:buttons => %W{ new_button }, 
                    :resource_types => %W{ site_updates },
                    :new_text => 'צור יחידת תוכן חדשה', 
                    :has_url => false, 
                    :placeholder => 'right'}).render_to(self)
                w_class('video_gallery').new().render_to(self)
                
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
      }
    }
  end     
  
  private 
  
  def right_column_resources
    @tree_nodes_right ||= TreeNode.get_subtree(
      :parent => tree_node.id, 
      :resource_type_hrids => ['site_updates'], 
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
