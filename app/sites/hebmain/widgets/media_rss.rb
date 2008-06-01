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
    rss_items = YAML.load(data) rescue nil
  end
    
  def render_show()
    content = get_items rescue nil
    if content.empty? || content.nil?
      CronManager.read_and_save_node_media_rss(tree_node, get_language)
    end
    
    content = get_items rescue nil
    return rawtext('') if content.empty? || content.nil?
    lessons = get_rss_items(content)
    if lessons.nil? || !lessons.is_a?(Hash) || lessons.empty?
      !lessons['lessons'] || !lessons['lessons'].is_a?(Hash) ||  
        !lessons['lessons']['lesson'] || !lessons['lessons']['lesson'].is_a?(Hash) 
      return rawtext('')
    end
    
    w_class('cms_actions').new(:tree_node => tree_node, :options => {:buttons => %W{ delete_button edit_button }, :position => 'bottom'}).render_to(doc)
    
    30.times do |j|
      curr_date = (Date.today - j).strftime('%d.%m.%Y')
      
      selected_lessons = lessons['lessons']['lesson'].select { |lesson|
        lesson['date'] && lesson['date'] == curr_date && 
          lesson['files'] && #lesson['files'].is_a?(Hash) &&
        lesson['files']['file'] #&& lesson['files']['file'].is_a?(Hash) && !lesson['files']['file'].empty?
      } 

      unless selected_lessons.empty?
        curr_date_to_show = (Date.today - j).strftime('%d.%m.%y')
        if has_lesson_in_site_language(selected_lessons)
          if (get_group_by_date)
            lesson_show(selected_lessons, curr_date_to_show)      
          else
            selected_lessons.each_with_index { |selected_lesson, index|
              lesson_show(Array.new(1,selected_lesson), curr_date_to_show, index)  
            }
          end
          return
        end
      end
    end
  end
  
  def has_lesson_in_site_language(lessons)
    lessons.each_with_index { |lesson, i|
      files_array = lesson['files']['file'].is_a?(Hash) ? Array.new(1,lesson['files']['file']) : lesson['files']['file']
      files_array.each { |file| 
        path = file['path'] rescue ''
        unless path.empty?
          if file['language'] && file['language'] == get_language
            return true
          end
        end
      }
    }
    return false
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
  
  def lesson_show(selected_lessons, curr_date, index = 0)
    div(:class => 'x-tree-arrows') {
      div(:class => 'toggle',
        :onclick => 'toggleUL("lesson-' + tree_node.id.to_s + index.to_s + '")',
        :onmouseover => 'mouseUL("lesson-' + tree_node.id.to_s + index.to_s +  '", true)',
        :onmouseout => 'mouseUL("lesson-' + tree_node.id.to_s + index.to_s +  '", false)'){
        img(:class => 'x-tree-ec-icon x-tree-elbow-plus', :src => '../ext/resources/images/default/s.gif',:alt => '')
        text get_title if get_title
        span(:class => 'date') { text ' ' + curr_date.to_s}
      }
          
      ul(:id => 'lesson-' + tree_node.id.to_s + index.to_s, :style => 'display:none;'){
        selected_lessons.each_with_index { |lesson, i|
          # Find video, audio, sirtut
          audio_href = ''
          video_href = ''
          sirtut_href = ''
          
          audio_found = false
          files_array = lesson['files']['file'].is_a?(Hash) ? Array.new(1,lesson['files']['file']) : lesson['files']['file']
          files_array.each do |file| 
            path = file['path'] rescue ''
            unless path.empty?
              if file['language'] && file['language'] == get_language
                if is_media_file(path, 'zip')
                  sirtut_href = path
                else 
                  if is_media_file(path, 'wmv')
                    video_href = path
                  else
                    if is_media_file(path, 'mp3') && !is_media_file(path, '96k.mp3')
                      audio_href = path
                      audio_found = true
                    else
                      if !audio_found && is_media_file(path, '96k.mp3')
                        audio_href = path
                      end
                    end
                  end
                end
              end
            end
          end
          
          if !video_href.empty? || !audio_href.empty? || !sirtut_href.empty?
            li(:class => 'item'){
              img(:class => 'x-tree-ec-icon x-tree-elbow', :src => '../ext/resources/images/default/s.gif',:alt => '')
              text lesson['title']
              div(:class => 'services'){
                a(:class => 'video', :href => video_href){span {text 'ואדיו'} } unless video_href.empty? 
                a(:class => 'audio', :href => audio_href){span {text 'וידוא'} } unless audio_href.empty?
                a(:class => 'sketch', :href => sirtut_href){span {text 'טוטרש'} } unless sirtut_href.empty?
              }
            }
          end
        }
      }
    }
  end
end