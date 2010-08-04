class Hebmain::Widgets::Sections < WidgetManager::Base
  
  def render_full
    div{
      div(:class => 'first')
      ul {
        li{
          a({:title => _(:kabbalah_la_am), :href => presenter.home}.merge!(gg_analytics_tracking(_(:home)))){
            rawtext ' '
            text  _(:home)     #' ראשי'
          }
        }
        main_sections.each_with_index{ |section, index|
          li(:class => 'divider'){ rawtext '|'}
          li(section.eql?(presenter.main_section) ? {:class => 'selected'} : {}){
            a({:class => "section_#{index}", :title => section.resource.name, :href => get_page_url(section)}.merge!(gg_analytics_tracking(section.resource.name))) {
              text section.resource.name
            }
          }
        }
      }
      div(:class => 'last')
    }
  end
  
  def main_sections
    presenter.main_sections
  end
  
  def gg_analytics_tracking (name_of_link = '')
    if presenter.is_homepage? 
      {:onclick => "javascript:google_tracker('/homepage/sections/#{name_of_link}');"}
    else
      {}
    end
  end
  
end
