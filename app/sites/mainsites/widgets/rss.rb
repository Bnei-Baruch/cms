require 'rss/1.0'
require 'rss/2.0'

class Mainsites::Widgets::Rss < WidgetManager::Base

  def initialize(*args, &block)
    super
    @language = get_language
    @web_node_url = get_page_url(@presenter.node)
  end

  def render_full
    items = get_all_items
    div(:class => 'rss'){
      rss_admin
      
      div(:class => 'h1') {
        text get_title
        div(:class =>'h1-right')
        div(:class =>'h1-left')
      }
      picture = get_picture
      text = get_description
      if (!(picture.empty? && text.empty?))
        div(:class => 'header'){
          img(:src => picture, :class =>'Rav Michael Laitman', :alt => 'image') if picture
          text text
          div(:class => 'clear')
        }
      end
      display_entries items, true
    }    
  end

  def render_preview
    id = tree_node.id
    div(:id => "rss#{id}"){}
    javascript {
        rawtext "$('#rss#{id}').load('#{@web_node_url}',{view_mode:'ajax','options[widget]':'rss','options[widget_node_id]':#{tree_node.id}})"
    }
  end

  def render_ajax
    items = get_all_items
   
    div(:class => 'rss container'){
      rss_admin
      
      h3(:class => 'box_header') {
        #        picture = get_picture
        #        img(:src => picture, :class =>'Rav Michael Laitman', :alt => 'image') if picture
        text get_title
      }
      display_entries items, false
    }
  end
  
  private
  
  def get_rss_items (data)
    rss_items = YAML.load(data) rescue nil
    if rss_items
      rss_items.map do |rss_item|
        {:title => (rss_item.title rescue ''), 
          :url => (rss_item.guid.content rescue ''),
          :aditional_url => (rss_item.link rescue ''),
          :date => (rss_item.pubDate rescue ''),
          :description => (rss_item.description rescue '')
        }
      end
    else
      nil         
    end
  end

  def get_all_items
    content = get_items
    if content.empty?
      CronManager.init_caches
      content = CronManager.read_and_save_node_rss(tree_node)
    end

    return nil if content.empty?
    get_rss_items(content)
  end

  def rss_admin
    w_class('cms_actions').new(:tree_node => tree_node, 
      :options => {:buttons => %W{ delete_button edit_button }, 
        :position => 'bottom',
        :button_text => "ניהול ה-RSS: #{get_title}",
        :new_text => 'הוסף RSS חדש'
      }).render_to(self)
  end

  def display_entries(items, show_description = true)
    if items.nil? || items.empty?
      text _(:'no_entries_yet_check_url')
      return
    end
    div(:class => 'entries'){
      items.each do |item|
        url = ''
        if !item[:url].empty? && !item[:aditional_url].empty?
          url = item[:aditional_url]
        else
          url = item[:url].empty? ? item[:aditional_url] : item[:url]
        end
        div(:class => 'entry'){
          a(:href => url, :target => '_blank' ) {rawtext item[:title]}
          if item[:date]
            div(:class => 'date'){
              text item[:date].strftime('%d.%m.%y, %H:%m')
            }
          end
          if (show_description && item[:description])
            div(:class => 'description'){
              rawtext item[:description]
            }
          end
        }
      end
      text = get_read_more_text
      a text, :href => get_read_more_url, :class => 'more', :target => '_blank' unless text.empty?
    }
  end

end
