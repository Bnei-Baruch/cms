class Hebmain::Widgets::Sections < Widget::Base
  attr_reader :resource, :view_mode
  
  def initialize(args_hash = {})
    super
    unless args_hash.is_a?(Hash)
      raise 'the parameter is not a hash'
    end
    @resource = args_hash[:tree_node].resource rescue nil
    @view_mode = args_hash[:view_mode] || 'full'
  end

  def render
    self.send(view_mode + '_mode')
  end
  
  def full_mode
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
