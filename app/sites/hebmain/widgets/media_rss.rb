require 'rss/1.0'
require 'rss/2.0'

class Hebmain::Widgets::MediaRss < WidgetManager::Base
  
  def render_full
    # default is lesson
    render_lesson
  end
  
  def render_lesson
    show_content
  end
  
  def render_lesson_in_table
    show_content_in_table
  end
  
  private
  
  def get_rss_items (data)
    rss_items = YAML.load(data) rescue nil
  end
    
  def show_content
    lessons = lesson_validation
    return rawtext('') if lessons.nil?
    
    w_class('cms_actions').new(:tree_node => tree_node, :options => {:buttons => %W{ delete_button edit_button }, :position => 'bottom'}).render_to(doc)
    
    days_num = get_days_num rescue 1
     
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
          days_num = days_num - 1
          return if days_num == 0
        end
      end
    end
  end
  
  def show_content_in_table
    lessons = lesson_validation
    return rawtext('') if lessons.nil?
    
    w_class('cms_actions').new(:tree_node => tree_node, :options => {:buttons => %W{ delete_button edit_button }, :position => 'bottom'}).render_to(doc)
    
    days_num = get_days_num rescue 1
     
    table(:border=>'1') {
      thead {
        tr {
          th 'Date'
          th 'Title'
          th 'Description'
          th 'Video'
          th 'Audio'
          th 'Sirtut'
        }
      }
      
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
              lessons_show_in_table(selected_lessons, curr_date_to_show)
            else
              selected_lessons.each { |selected_lesson|
                lessons_show_in_table(Array.new(1,selected_lesson), curr_date_to_show)   
              }
            end
            days_num = days_num - 1
            return if days_num == 0
          end
        end
      end
    }
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
    div(:class => 'toggle', :tree_node => tree_node.id.to_s + index.to_s){
      img(:class => 'x-plus', :src => '/images/hebmain/jquery/s.gif',:alt => '')
      text get_title if get_title
      span(:class => 'date') { text ' ' + curr_date.to_s}
    }
    
    ul(:id => 'lesson-' + tree_node.id.to_s + index.to_s, :style => 'display:none;'){
      selected_lessons.each { |lesson|
        # Find video, audio, sirtut
        video_href, audio_href, sirtut_href = lesson_links(lesson)
        
        if !video_href.empty? || !audio_href.empty? || !sirtut_href.empty?
          li(:class => 'item'){
            img(:class => 'x-', :src => '/images/hebmain/jquery/s.gif',:alt => '')
            text lesson['title']
            div(:class => 'services'){
              a(:class => 'video', :href => video_href){span {text 'וידאו'} } unless video_href.empty? 
              a(:class => 'audio', :href => audio_href){span {text 'אודיו'} } unless audio_href.empty?
              a(:class => 'sketch', :href => sirtut_href){span {text 'שרטוט'} } unless sirtut_href.empty?
            }
          }
        end
      }
    }
  end
  
  def lessons_show_in_table(selected_lessons, curr_date)
    selected_lessons.each_with_index { |lesson, i|
      video_href, audio_href, sirtut_href = lesson_links(lesson)
               
      tr {
        td curr_date.to_s
        if lesson['title']
          td lesson['title'] 
        else
          td ''
        end
        if lesson['description']
          td lesson['description'] 
        else
          td ''
        end
        
        td {
          a(:href => video_href) { 
            img(:class => 'img', :src => img_path('video.png'), :alt => '') unless video_href.empty? 
          }
        }
        td {
          a(:href => audio_href) { 
            img(:class => 'img', :src => img_path('audio.png'), :alt => '') unless audio_href.empty?
          }
        }
        td {
          a(:href => sirtut_href) { 
            img(:class => 'img', :src => img_path('video.png'), :alt => '') unless sirtut_href.empty?
          }
        }
      }
    }
  end
  
  def lesson_validation
    content = get_items rescue nil
    if content.empty? || content.nil?
      CronManager.read_and_save_node_media_rss(tree_node, get_language)
    end
    
    content = get_items rescue nil
    return nil if content.empty? || content.nil?
    lessons = get_rss_items(content)
    if lessons.nil? || !lessons.is_a?(Hash) || lessons.empty?
      !lessons['lessons'] || !lessons['lessons'].is_a?(Hash) ||  
        !lessons['lessons']['lesson'] || !lessons['lessons']['lesson'].is_a?(Hash) 
      return nil
    end
    return lessons
  end
  
  def lesson_links(lesson)
    video_href = ''
    audio_href = ''    
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
    return video_href, audio_href, sirtut_href
  end
  
end