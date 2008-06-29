class Hebmain::Widgets::Sections < WidgetManager::Base
  
  def render_full
    div{
      div(:class => 'first')
      ul {
        li{
          a(:href => presenter.home){
            img(:src => img_path('home.gif'), :alt => 'home')
            text ' ראשי'
          }
        }
        main_sections.each{ |section|
          li(:class => 'divider'){ rawtext '|'}
          li(section.eql?(presenter.main_section) ? {:class => 'selected'} : {}){
            a section.resource.name, :href => get_page_url(section)
          }
        }
      }
      div(:class => 'last')
    }
  end
  
  def main_sections
    presenter.main_sections
  end
end
