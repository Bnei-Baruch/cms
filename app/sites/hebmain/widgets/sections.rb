class Hebmain::Widgets::Sections < WidgetManager::Base
  
  def render_full
    ul {
      li{
        a(:href => presenter.home){
          img(:src => img_path('home.gif'), :alt => 'home')
        }
      }
      main_sections.each{ |section|
        li(:class => 'divider'){'|'}
        li(section.eql?(presenter.main_section) ? {:class => 'selected'} : {}){
          a section.resource.name, :href => get_page_url(section)
        }
      }
    }
  end
  
  def main_sections
    presenter.main_sections
  end
end
