require 'rss/1.0'
require 'rss/2.0'

class Hebmain::Widgets::Rss < WidgetManager::Base
  
  def render_full
    render_show
  end
  
  def render_preview
    render_show(false)  
  end
  
  private
  
  def get_rss_items (data)
    rss_items = YAML.load(data) rescue nil
    if rss_items
      rss_items.map do |rss_item|
        {:title => (rss_item.title rescue ''), 
          :url => (rss_item.guid.content rescue ''), 
          :date => (rss_item.pubDate rescue ''),
          :description => (rss_item.description rescue '')
        }
      end
    else
      nil         
    end
  end
  
  def render_show(show_description = true)

    content = get_items
    if content.empty?
      CronManager.read_and_save_node_rss(tree_node)
    end
    
    content = get_items
    return '' if content.empty?
    items = get_rss_items(content)

    return unless items
   
    div(:class => 'rss container'){
      w_class('cms_actions').new(:tree_node => tree_node, 
                                 :options => {:buttons => %W{ delete_button edit_button }, 
                                              :position => 'bottom',
                                              :button_text => "ניהול ה-RSS: #{get_title}",
                                              :new_text => 'הוסף RSS חדש'
                                              }).render_to(doc)
      h3(:class => 'box_header') {
        picture = get_picture
        img(:src => picture, :class =>'Rav Michael Laitman', :alt => 'image') if picture
        text get_title
      }

      div(:class => 'entries'){
        items.each do |item|
          div(:class => 'entry'){
            a item[:title], :href => item[:url]
            div(:class => 'date'){
              text item[:date].strftime('%d.%m.%y, %H:%m')
            }
            if (show_description)
              div(:class => 'description'){
                rawtext item[:description]
              }
            end
          }
        end
        a get_read_more_text, :href => get_read_more_url, :class => 'more'
      }
    }
  end
end