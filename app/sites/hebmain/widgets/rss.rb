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
    rss_items = YAML.load(data)  
  end
  
  def get_rss_items (data)
    rss_items = YAML.load(data)
    rss_items.map do |rss_item|
      {:title => rss_item.title, 
        :url => rss_item.guid.content, 
        :date => rss_item.pubDate,
        :description => rss_item.description
      }
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
   
    div(:class => 'rss'){
      w_class('cms_actions').new(:tree_node => tree_node, :options => {:buttons => %W{ delete_button edit_button }, :position => 'bottom'}).render_to(doc)
      h3 {
        text get_title
        picture = get_picture
        img(:src => picture, :class =>'Rav Michael Laitman', :alt => 'image') if picture
      }

      items.each do |item|
        div(:class => 'entry'){
          a item[:title], :href => item[:url]
          div(:class => 'date'){
            text item[:date].strftime('%d.%m.%Y, %H:%m')
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
  end
end