class Mainsites::Layouts::ContentPage < WidgetManager::Base

  attr_accessor :ext_content, :ext_title, :ext_main_image

  def initialize(*args, &block)
    super
    @header = w_class('header').new()
    @tree = w_class('tree').new()
    @breadcrumbs = w_class('breadcrumbs').new()

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
        css(get_css_url('inner_page'))
      }
      body {
        div(:id => 'doc2', :class => 'yui-t4') {
          div(:id => 'hd') { @header.render_to(self) } #Header goes here
          div(:id => 'bd') {
            div(:id => 'yui-main') {
              div(:class => 'yui-b') {
                div(:class => 'yui-ge') {
                  div(:class => 'menu') {
                    w_class('sections').new.render_to(self)
                  }    
                  div(:class => 'h1') {
                    img(:src => img_path('top-right.gif'),:class =>'right', :alt => '')
                    img(:src => img_path('top-left.gif'),:class =>'left', :alt => '')
                    text 'חגים בקבלה  |  ט”ו בשבט'
                  }
                    @breadcrumbs.render_to(self) 
                  div(:class => 'yui-u first') {
                    div(:class => 'content') { self.ext_content.render_to(doc) }
                  }
                  div(:class => 'yui-u') {
                    div(:class => 'related') {
                      self.ext_main_image.render_to(doc)
                      div(:class => 'box') {
                        div(:class => 'box-top'){rawtext('&nbsp;')}
                        div(:class => 'box-mid'){
                          h4 'מאמרים נוספים בנושא:'
                          ul{
                            li{a 'חג לאילנות', :href => '#', :title => ''}
                            li{a 'מה נאה אילן זה', :href => '#', :title => ''}
                            li{a 'תהליך צמיחה רוחני', :href => '#', :title => ''}
                            li{a 'ט”ו בשבט ברוחניות', :href => '#', :title => ''}
                          }
                        }
                        div(:class => 'box-bot'){rawtext('&nbsp;')}
                      }
                      div(:class => 'box') {
                        div(:class => 'box-top'){rawtext('&nbsp;')}
                        div(:class => 'box-mid'){
                          h4 'קישורים למקורות:'
                          ul{
                            li{
                              a(:href => '#', :title => ''){
                                text 'חג לאילנות'
                                span(:class => 'gray'){text '(הרב”ש)'}
                              }
                            }
                            li{
                              a(:href => '#', :title => ''){
                                text 'מה נאה אילן זה'
                                span(:class => 'gray'){text '(בעל הסולם)'}
                              }
                            }
                             li{
                              a(:href => '#', :title => ''){
                                text 'תהליך צמיחה רוחני'
                                span(:class => 'gray'){text '(בעל הסולם)'}
                              }
                            }
                             li{
                              a(:href => '#', :title => ''){
                                text 'ט”ו בשבט ברוחניות'
                                span(:class => 'gray'){text '(בעל הסולם)'}
                              }
                            }
                          }
                        }
                        div(:class => 'box-bot'){rawtext('&nbsp;')}
                      }
                    }
                  }
                }
              }
            }
            div(:class => 'yui-b') {
              div(:class => 'nav') {
                h4 {
                  img(:src => img_path('top-right.gif'), :class => 'right', :alt => '')
                  img(:src => img_path('top-left.gif'), :class => 'left', :alt => '')
                  text presenter.main_section.resource.name
                }
                @tree.render_to(doc)
              }
              div(:class => 'news') {
                div(:class => 'item') {
                  h4 'בוקר אור'
                  text 'היכנסו וקראו מה מרגיש וחושב מקובל ומדען על אירועי היום, על קבלה ועל משמעות החיים.'
                  br
                  a 'לצפיה בתוכנית מה 15.04', :href => '#', :title => 'link'
                  div(:class => 'border'){rawtext('&nbsp;')}
                }
                div(:class => 'item') {
                  h4 'בוקר אור'
                  text 'היכנסו וקראו מה מרגיש וחושב מקובל ומדען על אירועי היום, על קבלה ועל משמעות החיים.'
                  br
                  a 'לצפיה בתוכנית מה 15.04', :href => '#', :title => 'link'
                  div(:class => 'border'){rawtext('&nbsp;')}
                }
                div(:class => 'item') {
                  h4 'בוקר אור'
                  text 'היכנסו וקראו מה מרגיש וחושב מקובל ומדען על אירועי היום, על קבלה ועל משמעות החיים.'
                  br
                  a 'לצפיה בתוכנית מה 15.04', :href => '#', :title => 'link'
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