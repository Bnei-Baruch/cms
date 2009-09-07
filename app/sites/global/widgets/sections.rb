class Global::Widgets::Sections < WidgetManager::Base

  def render_full
    ul(:class => 'sf-menu'){
      # The first item is Homepage
      li{
        a({:href => presenter.home}.merge!(gg_analytics_tracking('homepage'))){
          img(:src => img_path('home.gif'), :alt => 'Homepage')
        }
      }
      # Only sections will be present in tree
      # Each item in tree is section and has array of :children
      tree = []
      idx = -1
      main_sections.inject(0){ |parent_id, section|
        if section.parent_id == parent_id
          ## this is child of the previousely found section
          tree[idx][:children] << section
        else
          # Section was found
          idx += 1
          tree[idx] = section
          tree[idx][:children] = []
          parent_id = section.id
        end
        parent_id
      }
      tree.each{ |section|
        li{
          a({:href => get_page_url(section)}.merge!(gg_analytics_tracking('top-level', section.resource.name))) {
            span {rawtext section.resource.name}
          }
          ul{
            section[:children].each{ |child|
              li{
                a({:href => get_page_url(child)}.merge!(gg_analytics_tracking('2nd-level', child.resource.name))) {
                  span {rawtext child.resource.name}
                }
              }
            }
          } unless section[:children].empty?
        }
      }
    }
  end

  private
  def main_sections
    presenter.main_sections(2)
  end
  
  def gg_analytics_tracking (level, name_of_link = '')
    if presenter.is_homepage? 
      {:onclick => "javascript:urchinTracker('/homepage/sections/#{level}/#{name_of_link}');"}
    else
      {}
    end
  end
  
end
