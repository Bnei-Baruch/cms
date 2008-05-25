require 'rss/1.0'
require 'rss/2.0'

class Hebmain::Widgets::MediaRss < WidgetManager::Base
  
  def render_full
    # default is lesson
    render_lesson
  end
  
  def render_lesson
    render_show
  end
  
  private
  
  def get_rss_items (data)
    rss_items = YAML.load(data)
  end
    
  def render_show(show_description = true)
    content = get_items
    if content.empty? | content.nil?
      CronManager.read_and_save_node_media_rss(tree_node, get_language)
    end
    
    content = get_items
    return '' if content.empty? | content.nil?
    lessons = get_rss_items(content)

    lessons['lessons']['lesson'].each do |lesson|
      lesson['date'] = (Time.parse(lesson['date'])).strftime('%d.%m.%Y') 
    end
    
    #div(:class => 'downloads'){
      get_days_num.times do |j|
        curr_date = (Date.today - j).strftime('%d.%m.%Y')
      
        selected_lessons = lessons['lessons']['lesson'].select { |lesson|
          lesson['date'] == curr_date
        }
      
        unless selected_lessons.empty?
          div(:class => 'x-tree-arrows') {
            div(:class => 'toggle',
              :onclick => 'toggleUL("lesson-' + curr_date.to_s + '")',
              :onmouseover => 'mouseUL("lesson-' + curr_date.to_s + '", true)',
              :onmouseout => 'mouseUL("lesson-' + curr_date.to_s + '", false)'){
              img(:class => 'x-tree-ec-icon x-tree-elbow-plus', :src => '../ext/resources/images/default/s.gif',:alt => '')
              text get_title + ' ' + curr_date.to_s
            }
          
            ul(:id => 'lesson-' + curr_date.to_s, :style => 'display:none;'){
              selected_lessons.each_with_index { |lesson, i|
                # Find video, audio, sirtut
                audio_href = ''
                video_href = ''
                sirtut_href = ''
          
                lesson['files']['file'].each do |file|  
                  len = file['path'].length
                  if file['language'] == get_language
                    if is_media_file(file['path'], 'zip')
                      sirtut_href = file['path']
                    else 
                      if is_media_file(file['path'], 'wmv')
                        video_href = file['path']
                      else
                        if is_media_file(file['path'], 'mp3')
                          audio_href = file['path']
                        else
                          if audio_href.empty? && is_media_file(file['path'], '96k.mp3')
                            audio_href = file['path']
                          end
                        end
                      end
                    end
                  end
                end
          
                li(:class => 'item'){
                  img(:class => 'x-tree-ec-icon x-tree-elbow', :src => '../ext/resources/images/default/s.gif',:alt => '')
                  text lesson['title']
                  div(:class => 'services'){
                    a(:class => 'video', :href => video_href){span {text 'וידאו'} } unless video_href.empty? 
                    a(:class => 'audio', :href => audio_href){span {text 'אודיו'} } unless audio_href.empty?
                    a(:class => 'sketch', :href => sirtut_href){span {text 'שרטוט'} } unless sirtut_href.empty?
                  }
                }
              }
            }
          }
        end
      end
    #}
    
    #    div(:class => 'rss'){
    #      w_class('cms_actions').new(:tree_node => tree_node, :options => {:buttons => %W{ delete_button edit_button }, :position => 'bottom'}).render_to(doc)
    #      h3 {
    #        text get_title
    #      }
    #
    #      items.each do |item|
    #        div(:class => 'entry'){
    #          a item[:title], :href => item[:url]
    #          div(:class => 'date'){
    #            text item[:date].strftime('%d.%m.%Y, %H:%m')
    #          }
    #          if (show_description)
    #            div(:class => 'description'){
    #              rawtext item[:description]
    #            }
    #          end
    #        }
    #      end
    #    }
  end
  
  def get_language
    lang = presenter.site_settings[:language] rescue 'english'
    return (lang[0..2]).upcase
  end
  
  def is_media_file(path, extension)
    len_path = path.length
    len_ext  = extension.length
    if (len_path < len_ext)
      return false
    end
    range = Range.new(len_path - len_ext, len_path, true)
    if path[range] == extension
      return true
    else
      return false
    end
  end
end