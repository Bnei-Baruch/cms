class Hebmain::Widgets::Map < Mainsites::Widgets::Sitemap

  def render_full
    modulu = 4
    @row = ''
    @column = ''

    w_class('cms_actions').new( :tree_node => tree_node,
      :options => {:buttons => %W{ edit_button delete_button },
        :resource_types => %W{ map },
        :new_text => 'צור יחידת תוכן חדשה',
        :has_url => false
      }).render_to(self)

    div(:class => "pagemap"){
      h3 {text get_title}
      table{
        presenter.main_sections.each_with_index {|section,index|
          modulu_result = (index+1)%modulu
          toggle_column
          if modulu_result==1
            toggle_row
            rawtext "<tr class='#{@row}'>"
          end
          sub_sections = get_sub_section(section) || []
          td(:class => @column){
            div{
              a section.resource.name, :href => get_page_url(section), :class => 'title'
            }
            ul{ 
              sub_sections.each {|section|
                li(:class => 'list'){
                  a(:href => get_page_url(section)){text section.resource.name}
                }
              }
            }
          } unless sub_sections.empty?
          rawtext "<tr>" if modulu_result == 0
        }
        div(:class => 'clear')
      }
    }
  end
   
  def toggle_column
    case @column
    when ''
      @column = 'odd'
    when 'odd'
      @column = 'even'
    when 'even'
      @column = 'odd'
    end
  end

  def toggle_row
    case @row
    when ''
      @row = 'odd'
    when 'odd'
      @row = 'even'
    when 'even'
      @row = 'odd'
    end
  end
end
