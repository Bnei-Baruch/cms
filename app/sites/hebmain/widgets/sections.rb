class Hebmain::Widgets::Sections < WidgetManager::Base
  
  def render_full
    div{
      div(:class => 'first')
      ul {
        li{
          a({:href => presenter.home}.merge!gg_analytics_tracking('ראשי')){
            img(:src => img_path('home.gif'), :alt => 'home')
            text ' ראשי'
          }
        }
        main_sections.each{ |section|
          li(:class => 'divider'){ rawtext '|'}
          li(section.eql?(presenter.main_section) ? {:class => 'selected'} : {}){
            a ({:href => get_page_url(section)}.merge!gg_analytics_tracking(section.resource.name)) {
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
      {:onclick => "javascript:urchinTracker('/homepage/sections/#{name_of_link}');"}
    else
      {}
    end
  end
  
end
