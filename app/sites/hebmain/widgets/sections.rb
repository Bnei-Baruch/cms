class Hebmain::Widgets::Sections < WidgetManager::Base
  
  def render_full
    div{
      div(:class => 'first')
      ul {
        li{
          a({:title => _(:kabbalah_la_am), :href => presenter.home}.merge!(gg_analytics_tracking(_(:home)))){
            rawtext ' '
            text  _(:home)
          }
        }
        main_sections.each_with_index{ |section, index|
          li(:class => 'divider'){ rawtext '|'}
          li(section.eql?(presenter.main_section) ? {:class => 'selected'} : {}){
            if section.permalink == $config_manager.site_settings(@presenter.website.hrid)[:ligdoltv]
              section = ligdoltv_first_link
              a({:class => "section_#{index}", :title => section.resource.name, :href => get_page_url(section)}.merge!(gg_analytics_tracking(section.resource.name))) {
                text section.resource.name
              }
            else
              a({:class => "section_#{index}", :title => section.resource.name, :href => get_page_url(section)}.merge!(gg_analytics_tracking(section.resource.name))) {
                text section.resource.name
              }
            end
          }
        }
      }
      div(:class => 'last')
    }
  end
  
  def render_ligdoltv
    parents = presenter.node.parents
    bgcolor = '#cccccc'
    home_url = get_page_url(presenter.main_section)
    
    # Upper level
    ul(:id => :upper_menu) {
      ligdoltv_main_sections.each_with_index{ |section, index|
        if ligdoltv_selected(section, parents)
          bgcolor = section.resource.properties('tab_color')['string_value']
          style = {:style => "background-color: #{bgcolor};"}
          home_url = get_page_url(section)
        else
          style = {}
        end
        li(style){
          a({:class => "section_#{index}", :title => section.resource.name, :href => get_page_url(section)}.merge!(gg_analytics_tracking(section.resource.name))) {
            text section.resource.name
          }
        }
      }
    }
    ul(:id => :bottom_menu, :style => "background-color: #{bgcolor}") {
      li(:style => "background-color: #{bgcolor}"){
        a({:title => _(:home), :href => home_url}.merge!(gg_analytics_tracking(presenter.main_section.resource.name))){
          rawtext ' '
          text  _(:home)
        }

      }
      ligdoltv_sub_sections(presenter.node).each_with_index{ |section, index|
        li(:style => "background-color: #{bgcolor}"){
          a({:class => "section_#{index}", :title => section.resource.name, :href => get_page_url(section)}.merge!(gg_analytics_tracking(section.resource.name))) {
            text section.resource.name
          }
        }
      }
    }
  end

  private

  def ligdoltv_selected(node, parents)
    parents.include?(node) || node.eql?(presenter.node)
  end
  
  def ligdoltv_first_link
    ligdoltv_main_sections[0]
  end

  def ligdoltv_sub_sections(node)
    ligdoltv_get_subtree(node.id)
  end
  
  def ligdoltv_main_sections
    @parent_id ||= TreeNode.find_by_permalink($config_manager.site_settings(@presenter.website.hrid)[:ligdoltv]).id
    @ligdoltv_main_sections ||= ligdoltv_get_subtree(@parent_id)
  end
  
  def ligdoltv_get_subtree(parent_id)
      TreeNode.get_subtree(
      :parent => parent_id,
      :resource_type_hrids => ['content_page'],
      :depth => 1,
      :has_url => true,
      :properties => 'b_hide_on_navigation = false'
    )
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
