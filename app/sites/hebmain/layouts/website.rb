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
        css(get_css_url('header'))
        css(get_css_url('home_page'))
        css(get_css_url('page_admin'))
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
                    div(:class => 'left-part') { text 'left-part' }
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
