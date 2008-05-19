class Hebmain::Layouts::Website < WidgetManager::Layout

  attr_accessor :ext_content, :ext_title, :ext_main_image, :ext_related_items

  def initialize(*args, &block)
    super
    @header = w_class('header').new()
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
        css(get_css_external_url('reset-fonts-grids'))
        css(get_css_external_url('base-min'))
#        css(get_css_external_url('../ext/resources/css/ext-all'))
        css(get_css_external_url('../ext/resources/css/reset'))
        css(get_css_external_url('../ext/resources/css/core'))
        css(get_css_external_url('../ext/resources/css/layout'))
        css(get_css_external_url('../ext/resources/css/panel'))
        css(get_css_external_url('../ext/resources/css/borders'))
        css(get_css_external_url('../ext/resources/css/tabs'))
        css(get_css_url('header'))
        css(get_css_url('home_page'))
        css(get_css_url('page_admin'))
        rawtext <<-ExtJS
          <script src="/javascripts/../ext/adapter/ext/ext-base.js" type="text/javascript"></script>
          <script src="/javascripts/../ext/ext-tabs-tree.js" type="text/javascript"></script>
          <script src="/javascripts/ext-helpers.js" type="text/javascript"></script>
        ExtJS
        #javascript(:src => "../javascripts/prototype.js")
        #javascript(:src => "../javascripts/scriptaculous.js?load=effects")
        #javascript(:src => "../ext/adapter/prototype/ext-prototype-adapter.js")
        #javascript(:src => "../ext/ext-all-debug.js")
        javascript {
          rawtext 'Ext.util.CSS.swapStyleSheet("theme","ext/resources/css/xtheme-gray.css");'
          rawtext 'Ext.BLANK_IMAGE_URL="/ext/resources/images/default/s.gif";'
        }
      }
      body {
        div(:id => 'doc2', :class => 'yui-t5') {
          div(:id => 'hd') { @header.render_to(self) } #Header goes here
          div(:id => 'bd') {
            div(:id => 'yui-main') {
              div(:class => 'yui-b') {
                div(:class => 'yui-gd') {
                  div(:class => 'menu') {
                    w_class('sections').new.render_to(self)
                  }    
                  div(:class => 'yui-u first') {
                    div(:class => 'h1') {
                      text 'קבלה online'
                      img(:src => img_path('top-right.gif'),:class =>'h1-right', :alt => '')
                      img(:src => img_path('top-left.gif'),:class =>'h1-left', :alt => '')
                    }
                    div(:class => 'left-part') {
                      div(:id => 'tabs1', :class => 'radio-TV') {
                      }
                      div(:id => 'tv', :class => 'x-hide-display body'){
                        rawtext <<-TV
                        <object classid="clsid:6BF52A52-394A-11D3-B153-00C04F79FAA6"
style="display:inline;background-color:#000000;" id="player" name="player" type="video/x-ms-wmv"
  width="200" height="150" standby="Loading Windows Media Player components...">
<param name="URL" value="http://files.kab.co.il/video/ger_t_rav_bs-matan-tora_2008-05-18_shiur_bb.wmv" />
<param name="AutoStart" value="1" /><param name="AutoPlay" value="1" />
<param name="volume" value="50" /><param name="uiMode" value="none" />
<param name="animationAtStart" value="1" /><param name="showDisplay" value="1" />
<param name="transparentAtStart" value="0" />
<param name="bgcolor" value="#000000" />
<param name="balance" value="0" />
  <embed id="player" name="player" style="display:inline;background-color:#000000;"
src="http://files.kab.co.il/video/ger_t_rav_bs-matan-tora_2008-05-18_shiur_bb.wmv"
 type="video/x-ms-wmv"
pluginspage="http://activex.microsoft.com/activex/controls/mplayer/en/nsmp2inf.cab#Version=6,4,7,1112"
 autostart="true" uimode="none" width="200" height="150" />
</object>
                        TV
                        div(:class => 'clear'){
                          a _('Watch in full window'), :href => ''
                        }
                      }
                      div(:id => 'radio', :class => 'x-hide-display body'){
                        rawtext 'RADIO'
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
                                startPlayer();
                              } else {
                                pausePlayer();
                              }
                            });
function startPlayer()
{
var player = document.getElementById("player");
 if (player && player.controls && player.controls.isAvailable('Play')){
 player.controls.play();
}
}

function pausePlayer()
{
var player = document.getElementById("player");
 if (player && player.controls && player.controls.isAvailable('Pause')) {
 player.controls.pause();
}
}
                          }
                        EXT_ONREADY
                      }
                      div(:class => 'rss'){
                        h3 {
                          text 'בלוג של הרב לייטמן'
                          img(:src => img_path('rav.jpg'),:class =>'Rav Michael Laitman', :alt => '')
                        }
                        
                        div(:class => 'entry'){
                          a 'גם בעלי תפקידים, גם תלמידים, גם בני משפחה', :href => '#'
                          div(:class => 'date'){
                            text '28/04  08:05'
                          }
                        }
                        div(:class => 'entry'){
                          a 'אנו זקוקים לחומרים חדשים ונגישים', :href => '#'
                          div(:class => 'date'){
                            text '28/04  18:54'
                          }
                        }
                        a 'לקריאת פוסטים נוספים...', :href => '#', :class => 'more'
                      }
                    }
                  }
                  div(:class => 'yui-u') {
                    div(:class => 'h1') {
                      text 'קבלה ללומד'
                      img(:src => img_path('top-right.gif'),:class =>'h1-right', :alt => '')
                      img(:src => img_path('top-left.gif'),:class =>'h1-left', :alt => '')
                    }
                    div(:class => 'content') {
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
                div(:class => 'updates'){
                  h3 'עידכונים'
                  div(:class => 'update'){
                    h4 'שיבת החברים העולמית! '
                    rawtext 'בכל יום א&amp; בשעה 19:00 תשודר בשידור חי ישיבת החברים העולמית.'
                    div(:class => 'link'){
                      a(:href => '#', :title => 'link') {
                        rawtext 'צפו בישיבה האחרונה'
                        img(:src => img_path('arrow-left.gif'), :alt => '')
                      }
                    }
                  }
                  div(:class => 'update last'){
                    h4 'שיבת החברים העולמית! '
                    rawtext 'בכל יום א&amp; בשעה 19:00 תשודר בשידור חי ישיבת החברים העולמית.'
                    div(:class => 'link'){
                      a(:href => '#', :title => 'link') {
                        rawtext 'צפו בישיבה האחרונה'
                        img(:src => img_path('arrow-left.gif'), :alt => '')
                      }
                    }
                  }
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
end 
