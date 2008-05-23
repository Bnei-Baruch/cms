class Hebmain::Layouts::Website < WidgetManager::Layout

  attr_accessor :ext_content, :ext_title, :ext_main_image, :ext_related_items

  def initialize(*args, &block)
    super
    @header_left = w_class('header').new(:view_mode => 'left')
    @header_right = w_class('header').new(:view_mode => 'right')
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
        stylesheet_link_tag 'reset-fonts-grids', 
        'base-min',
        '../ext/resources/css/ext-all', 
        get_css_url('header'), 
        get_css_url('home_page'),
        get_css_url('page_admin'),
        :cache => false
        javascript_include_tag '../ext/adapter/ext/ext-base', '../ext/ext-all', 'ext-helpers'#, :cache => true
        javascript {
          rawtext 'Ext.util.CSS.swapStyleSheet("theme","ext/resources/css/xtheme-gray.css");'
          rawtext 'Ext.BLANK_IMAGE_URL="/ext/resources/images/default/s.gif";'
        }
      }
      body {
        div(:id => 'doc2', :class => 'yui-t5') {
          div(:id => 'bd') {
            div(:id => 'yui-main') {
              div(:class => 'yui-b') {
                div(:class => 'yui-gd') {
                  @dynamic_tree.render_to(doc)
                  div(:id => 'hd') { @header_left.render_to(self) } #Header goes here
                  div(:class => 'menu') {
                    w_class('sections').new.render_to(self)
                  }    
                  div(:class => 'yui-u first') {
                    div(:class => 'left-part') {
                      div(:class => 'h1') {
                        text 'קבלה online'
                        img(:src => img_path('top-right.gif'),:class =>'h1-right', :alt => '')
                        img(:src => img_path('top-left.gif'),:class =>'h1-left', :alt => '')
                      }
                      div(:id => 'tabs1', :class => 'radio-TV') {
                      }
                      div(:id => 'tv', :class => 'x-hide-display body'){
                        #javascript {rawtext 'if (Ext.isIE) {'}
                        rawtext <<-TV
<object classid="clsid:6BF52A52-394A-11D3-B153-00C04F79FAA6"
style="display:inline;background-color:#000000;" id="tv-player" type="application/x-oleobject"
width="200" height="150" standby="Loading Windows Media Player components...">
<param name="URL" value="http://files.kab.co.il/video/ger_t_rav_bs-matan-tora_2008-05-18_shiur_bb.wmv" />
<param name="AutoStart" value="1" /><param name="AutoPlay" value="1" /><param name="volume" value="50" />
<param name="uiMode" value="full" /><param name="animationAtStart" value="1" />
<param name="showDisplay" value="1" /><param name="transparentAtStart" value="0" />
<param name="ShowControls" value="1" /><param name="ShowStatusBar" value="1" />
<param name="ClickToPlay" value="0" /><param name="bgcolor" value="#000000" />
<param name="windowlessVideo" value="1" /><param name="balance" value="0" />
<embed id="tv-player"
src="http://files.kab.co.il/video/ger_t_rav_bs-matan-tora_2008-05-18_shiur_bb.wmv"
type="application/x-mplayer2"
pluginspage="http://activex.microsoft.com/activex/controls/mplayer/en/nsmp2inf.cab#Version=6,4,7,1112"
autostart="true" uimode="full" width="200" height="150" />
</object>
                        TV
                        div(:class => 'clear'){
                          a _('Watch in full window'), :href => ''
                        }
                      }
                      div(:id => 'radio', :class => 'x-hide-display body'){
                        rawtext <<-RADIO
<object classid="clsid:6BF52A52-394A-11D3-B153-00C04F79FAA6"
style="display:inline;background-color:#000000;" id="tv-player" type="application/x-oleobject"
width="200" height="150" standby="Loading Windows Media Player components...">
<param name="URL" value="mms://vod.kab.tv/radioheb" />
<param name="AutoStart" value="1" /><param name="AutoPlay" value="1" /><param name="volume" value="50" />
<param name="uiMode" value="mini" /><param name="animationAtStart" value="1" />
<param name="showDisplay" value="1" /><param name="transparentAtStart" value="0" />
<param name="ShowControls" value="1" /><param name="ShowStatusBar" value="1" />
<param name="ClickToPlay" value="0" /><param name="bgcolor" value="#000000" />
<param name="windowlessVideo" value="1" /><param name="balance" value="0" />
<embed id="tv-player"
src="mms://vod.kab.tv/radioheb"
type="application/x-mplayer2"
pluginspage="http://activex.microsoft.com/activex/controls/mplayer/en/nsmp2inf.cab#Version=6,4,7,1112"
autostart="true" uimode="mini" width="200" height="45" />
</object>
                        RADIO
                      }
                      javascript {
                        # Start onReady
                        rawtext <<-EXT_ONREADY
                          Ext.onReady(function(){
                            tabs();
                          });
                          tabs = function(){
                            var mytab = new Ext.TabPanel({
                              renderTo: 'tabs1',
                              width:222,
                              activeTab:0,
                              frame:true,
                              resizeTabs:true,
                              items:[
                                  {contentEl:'radio', title: 'רדיו' },
                                  {contentEl:'tv', title: 'טלויזיה' }
                              ]
                            });
                            mytab.on('tabchange', function(panel, tab){
                              if (tab.contentEl == "tv"){
                                pausePlayer("r-player");
                                startPlayer("tv-player");
                              } else {
                                pausePlayer("tv-player");
                                startPlayer("r-player");
                              }
                            });
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
                          };
                        EXT_ONREADY
                      }
                      javascript{
                        rawtext <<-toggleUL
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
                      toggleUL
                      }
                      div(:class => 'downloads'){
                        h3 'הורדות חינם'
                        div(:class => 'x-tree-arrows') {
                          div(:class => 'toggle',
                              :onclick => 'toggleUL("download-122")',
                              :onmouseover => 'mouseUL("download-122", true)',
                              :onmouseout => 'mouseUL("download-122", false)'){
                            img(:class => 'x-tree-ec-icon x-tree-elbow-plus', :src => '../ext/resources/images/default/s.gif',:alt => '')
                            text 'שיעור הבוקר היומי' + ' 26.04.08'
                          }
                          ul(:id => 'download-122', :style => 'display:none;'){
                            li(:class => 'item'){
                              img(:class => 'x-tree-ec-icon x-tree-elbow', :src => '../ext/resources/images/default/s.gif',:alt => '')
                              span {text 'הקדמה לספר הזוהר, אות מ"א, שיעור 13'}
                              div(:class => 'services'){
                                a(:class => 'video'){span {text 'וידאו'} }
                                a(:class => 'audio'){span {text 'אודיו'} }
                                a(:class => 'sketch'){span {text 'שרטוט'} }
                              }
                            }
                            li(:class => 'item'){
                              img(:class => 'x-tree-ec-icon x-tree-elbow', :src => '../ext/resources/images/default/s.gif',:alt => '')
                              text 'תע"ס, כרך א, חלק ג, חלק ג, , דף ר"ג'
                              div(:class => 'services'){
                                a(:class => 'video'){text 'וידאו' }
                                a(:class => 'audio'){text 'אודיו' }
                                a(:class => 'sketch'){text 'שרטוט' }
                              }
                            }
                          }
                        }
                        div(:class => 'x-tree-arrows') {
                          div(:class => 'toggle',
                              :onclick => 'toggleUL("download-123")',
                              :onmouseover => 'mouseUL("download-123", true)',
                              :onmouseout => 'mouseUL("download-123", false)'){
                            img(:class => 'x-tree-ec-icon x-tree-elbow-plus', :src => '../ext/resources/images/default/s.gif',:alt => '')
                            text 'שיעור הבוקר היומי' + ' 26.04.08'
                          }
                          ul(:id => 'download-123', :style => 'display:none;'){
                            li(:class => 'item'){
                              img(:class => 'x-tree-ec-icon x-tree-elbow', :src => '../ext/resources/images/default/s.gif',:alt => '')
                              text 'הקדמה לספר הזוהר, אות מ"א, שיעור 13'
                              div(:class => 'services'){
                                a(:class => 'video'){text 'וידאו' }
                                a(:class => 'audio'){text 'אודיו' }
                                a(:class => 'sketch'){text 'שרטוט' }
                              }
                            }
                            li(:class => 'item'){
                              img(:class => 'x-tree-ec-icon x-tree-elbow', :src => '../ext/resources/images/default/s.gif',:alt => '')
                              text 'תע"ס, כרך א, חלק ג, חלק ג, , דף ר"ג'
                              div(:class => 'services'){
                                a(:class => 'video'){text 'וידאו' }
                                a(:class => 'audio'){text 'אודיו' }
                                a(:class => 'sketch'){text 'שרטוט' }
                              }
                            }
                          }
                        }
                      }
                      w_class('cms_actions').new(:tree_node => tree_node, 
                        :options => {:buttons => %W{ new_button }, 
                          :resource_types => %W{ rss },
                          :new_text => 'צור יחידת תוכן חדשה', 
                          :has_url => false, 
                          :placeholder => 'left'}).render_to(self)
              
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
                        img(:src => img_path('top-right.gif'),:class =>'h1-right', :alt => '')
                        img(:src => img_path('top-left.gif'),:class =>'h1-left', :alt => '')
                      }
                      div(:class => 'item') {
                        div(:class => 'main_preview1') {
                          div(:class => 'element last') {
                            h1 'ט"ו בשבט - חג המקובלים'
                            h2 'חג הצמיחה הרוחנית'
                            div(:class => 'descr') { text 'ט"ו בשבט מביא עִמו את תחילתה של העונה הקסומה ביותר בשנה. האוויר הופך צלול, השמים מתבהרים וקרני השמש חודרות מבעד לצמרות העצים. החורף כמעט חלף והאביב נראה בפתח. '}
                            div(:class => 'author') {
                              span'תאריך: ' + '04.03.2008', :class => 'right' #unless get_date.empty?
                              a(:class => 'left') { text "...לכתבה" }
                            }
                            img(:src => img_path('apple-tree-preview1.jpg'), :alt => 'preview')
                          }
                        }
                      }
                      
                      div(:class => 'item') {
                        div(:class => 'section_preview') {
                          div(:class => 'element'){
                            h1 'ט"ו בשבט - חג המקובלים'
                            div(:class => 'descr') { text 'ט"ו בשבט מביא עִמו את תחילתה של העונה הקסומה ביותר בשנה. האוויר הופך צלול, השמים מתבהרים וקרני השמש חודרות מבעד לצמרות העצים. החורף כמעט חלף והאביב נראה בפתח. '}
                            div(:class => 'author') {
                              span'תאריך: ' + '04.03.2008', :class => 'right' #unless get_date.empty?
                              a(:class => 'left') { text "...לכתבה" }
                            }
                            img(:class => 'img', :src => img_path('pesah-p1.jpg'), :alt => 'preview')
                          }
                          div(:class => 'element'){
                            h1 'ט"ו בשבט - חג המקובלים'
                            div(:class => 'descr') { text 'ט"ו בשבט מביא עִמו את תחילתה של העונה הקסומה ביותר בשנה. האוויר הופך צלול, השמים מתבהרים וקרני השמש חודרות מבעד לצמרות העצים. החורף כמעט חלף והאביב נראה בפתח. '}
                            div(:class => 'author') {
                              span'תאריך: ' + '04.03.2008', :class => 'right' #unless get_date.empty?
                              a(:class => 'left') { text "...לכתבה" }
                            }
                            img(:class => 'img', :src => img_path('pesah-p1.jpg'), :alt => 'preview')
                          }
                        }
                      }

                      div(:class => 'item') {
                        div(:class => 'main_preview3') {
                          div(:class => 'element') {
                            h3 'מגזין'
                            img(:src => img_path('magazin.jpg'), :alt => 'preview')
                            h4 'גיליון 2 של המגזין קבלה לעם'
                            ul(:class => 'links'){
                              li{a 'להורדת גרסת PDF'}
                              li{a 'להורדת גרסת Word'}
                              li{a 'למגזין האלקטרוני'}
                            }
                          }
                          div(:class => 'element') {
                            h3 'עיתון'
                            img(:src => img_path('magazin.jpg'), :alt => 'preview')
                            h4 'גיליון 28 של העיתון קבלה לעם'
                            ul(:class => 'links'){
                              li{a 'להורדת גרסת PDF'}
                              li{a 'להורדת גרסת Word'}
                              li{a 'למגזין האלקטרוני'}
                            }
                          }
                          div(:class => 'element last') {
                            h3 'ספר'
                            img(:src => img_path('magazin.jpg'), :alt => 'preview')
                            h4 'אישי ציבור ואומנים משוחחים על משמעות החיים'
                            ul(:class => 'links'){
                              li{a 'להורדת גרסת PDF'}
                              li{a 'להורדת גרסת Word'}
                              li{a 'למגזין האלקטרוני'}
                            }
                          }
                          div(:class => 'clear')
                        }
                      }
                    }
                  }
                }
              }
            }
            div(:class => 'yui-b') {
              div(:id => 'hd-r') { @header_right.render_to(self) } #Logo goes here
              div(:class => 'right-part') {
                div(:class => 'h1') {
                  text 'מאיפה להתחיל?'
                  img(:src => img_path('top-right.gif'),:class =>'h1-right', :alt => '')
                  img(:src => img_path('top-left.gif'),:class =>'h1-left', :alt => '')
                }
                div(:class => 'player') {
                  img(:src => img_path('player/player.jpg'), :alt => '')
                  ul{
                    li {a 'מה היא קבלה?'}
                    li {a 'האם הקבלה קשורה לדת?'}
                    li {a 'למי מותר ללמוד קבלה?'}
                    li(:class => 'more') {a 'לשאלות נוספות...', :href => '#', :title => 'link'}
                  }
                }
                
                w_class('cms_actions').new(:tree_node => tree_node, 
                  :options => {:buttons => %W{ new_button }, 
                    :resource_types => %W{ site_updates },
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
            text 'Footer'
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
  
end 
