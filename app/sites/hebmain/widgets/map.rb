class Hebmain::Widgets::Map < Mainsites::Widgets::Sitemap
  def render_full
    w_class('cms_actions').new( :tree_node => tree_node,
      :options => {:buttons => %W{ edit_button delete_button },
        :resource_types => %W{ map },
        :new_text => 'צור יחידת תוכן חדשה',
        :has_url => false
      }).render_to(self)

    div(:class => "pagemap"){
      h3 {text get_title}
      br
      div(:class => 'sitemap'){
        div(:class => 'sitemap-inner'){
          
          presenter.main_sections.each_with_index {|section,index|
            
            sub_sections = get_sub_section(section) || []

             ul(:class => 'box index'+index.to_s){
              li {
                a section.resource.name, :href => get_page_url(section), :class => 'title'
                ul{
                  sub_sections.each {|section|
                    li(:class => 'list'){
                      a(:href => get_page_url(section)){text section.resource.name}
                    }
                  }
                }
              }
            } unless sub_sections.empty?
          }
          div(:class => 'clear')
        }
      }
    }
  end
end
