require 'rss/1.0'
require 'rss/2.0'

class Mainsites::Widgets::MediaRss < WidgetManager::Base

  def initialize(*args, &block)
    super
    @language, @site_name = get_settings
    @web_node_url = get_page_url(@presenter.node)
  end

  def render_left
    id = tree_node.id
    div(:id => "rss_media#{id}", :class => 'box-content'){}
    javascript {
      rawtext "$('#rss_media#{id}').load('#{@web_node_url}',{view_mode:'ajax','options[widget]':'media_rss','options[widget_node_id]':#{tree_node.id}})"
    }
  end
  alias_method :render_preview, :render_left

  def render_homepage
    resources = TreeNode.get_subtree(
      :parent => tree_node.id,
      :resource_type_hrids => ['media_rss'],
      :depth => 1,
      :has_url => false,
      :status => ['PUBLISHED', 'DRAFT']
    )

    div(:class => 'downloads container'){
      w_class('cms_actions').new(:tree_node => tree_node,
        :options => {:buttons => %W{ new_button },
          :resource_types => %W{ media_rss },
          :new_text => _(:new_download),
          :mode => 'inline',
          :button_text => _(:add_downloads),
          :has_url => false,
          :placeholder => 'lesson'}).render_to(self)
      h3(:class => 'box-header') {
        text _(:lessons_to_download)
      }
      div(:class => 'entries'){
        show_content_resources(:resources => resources,
          :parent => :website,
          :placeholder => :lesson,
          :force_mode => 'preview',
          :sortable => true
        )
      }
      make_sortable(:selector => ".downloads .entries", :direction => 'y') {
        resources
      }
    }
  end

  def render_ajax
    w_class('cms_actions').new(:tree_node => tree_node, :options => {:buttons => %W{ delete_button edit_button }, :position => 'bottom'}).render_to(self)

    lessons = lesson_validation
    return rawtext('') if lessons.nil?

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
            lesson_show(selected_lessons, curr_date_to_show, j)
          else
            selected_lessons.each { |selected_lesson|
              lesson_show(Array.new(1,selected_lesson), curr_date_to_show, j)
            }
          end
          days_num = days_num - 1
          break if days_num == 0
        end
      end
    end
  end
  
  def render_full
    lessons = lesson_validation
    return rawtext('') if lessons.nil?
    
    w_class('cms_actions').new(:tree_node => tree_node, :options => {:buttons => %W{ delete_button edit_button }, :position => 'bottom'}).render_to(self)
    
    days_num = get_days_num rescue 1
    table(:class => "media_rss") {
      thead {
        tr {
          th(:class => 'top-right-corner'){ text _(:'date')}
          th _(:'name')
          th _(:'video')
          th _(:'audio')
          th(:class => 'top-left-corner'){ text _(:'picture')}
        }
      }

      group_by_date = get_group_by_date
      30.times { |j|
        curr_date = (Date.today - j).strftime('%d.%m.%Y')
	      
        selected_lessons = lessons['lessons']['lesson'].select { |lesson|
          lesson['date'] && (lesson['date'] == curr_date) && 
            lesson['files'] && lesson['files']['file']
        } 
	
        unless selected_lessons.empty?
          curr_date_to_show = (Date.today - j).strftime('%d.%m.%y')
          if has_lesson_in_site_language(selected_lessons)
            if (group_by_date)
              lessons_show_in_table(selected_lessons, curr_date_to_show)
            else
              selected_lessons.each { |selected_lesson|
                lessons_show_in_table(Array.new(1,selected_lesson), curr_date_to_show)   
              }
            end
            days_num = days_num - 1
            break if days_num == 0
          end
        end
      }
    }
  end
  
  private
  
  def get_rss_items (data)
    YAML.load(data) rescue nil
  end
    
  def has_lesson_in_site_language(lessons)
    lessons.each_with_index { |lesson, i|
      files_array = lesson['files']['file'].is_a?(Hash) ? Array.new(1,lesson['files']['file']) : lesson['files']['file']
      files_array.each { |file| 
        path = file['path'] rescue ''
        unless path.empty?
          if file['language'] && file['language'] == @language
            return true
          end
        end
      }
    }
    return false
  end

  def get_settings
    lang = presenter.site_settings[:language] rescue 'english'
    site = presenter.site_settings[:site_name] rescue 'english'
    return (lang[0..2]).upcase, site
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
  
  def lesson_show(selected_lessons, curr_date, index)
    empty_image = "/images/#{@site_name}/jquery/s.gif"
    div(:class => 'toggle', :tree_node => tree_node.id.to_s + index.to_s){
      img(:class => 'x-plus', :src => empty_image, :alt => '')
      text get_title if get_title
      span(:class => 'date') {text ' ' + curr_date.to_s}
    }
    
    ul(:id => 'lesson-' + tree_node.id.to_s + index.to_s, :style => 'display:none;'){
      selected_lessons.each { |lesson|
        # Find video, audio, sirtut
        video_href, audio_href, sirtut_href = lesson_links(lesson)
        
        if !video_href.empty? || !audio_href.empty? || !sirtut_href.empty?
          li(:class => 'item'){
            img(:class => 'x-', :src => empty_image, :alt => '')
            text lesson['title']
            div(:class => 'services'){
              a(:class => 'video', :href => video_href){span {text _(:'video')} } unless video_href.empty?
              a(:class => 'audio', :href => audio_href){span {text _(:'audio')} } unless audio_href.empty?
              a(:class => 'sketch', :href => sirtut_href){span {text _(:'audio')} } unless sirtut_href.empty?
            }
          }
        end
      }
    }
  end
  
  def lessons_show_in_table(selected_lessons, curr_date)
    selected_lessons.each_with_index { |lesson, i|
      video_href, audio_href, sirtut_href = lesson_links(lesson)
               
      tr(:class => 'mouse-grey-over') {
        td(:class => 'right-cell date-rss'){text curr_date.to_s}
        td(:class => 'name-cell'){text lesson['title'] || ''}
        
        td(:class => 'icon-cell icon-rss'){
          a(:href => video_href) { 
            img(:class => 'img', :src => img_path('video.png'), :alt => '') unless video_href.empty? 
          }
        }
        td(:class => 'icon-cell icon-rss'){
          a(:href => audio_href) { 
            img(:class => 'img', :src => img_path('audio.png'), :alt => '') unless audio_href.empty?
          }
        }
        td(:class => 'left-cell icon-rss') {
          a(:href => sirtut_href) { 
            img(:class => 'img', :src => img_path('skric.gif'), :alt => '') unless sirtut_href.empty?
          }
        }
      }
    }
  end
  
  def lesson_validation
    content = get_items rescue nil
    if content.empty? || content.nil?
      CronManager.read_and_save_node_media_rss(tree_node, get_language)
      content = get_items rescue nil
    end
    
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
    language = get_language
    
    video_href = ''
    audio_href = ''    
    sirtut_href = ''
          
    audio_found = false
    (lesson['files']['file'].is_a?(Hash) ? [lesson['files']['file']] : lesson['files']['file']).each do |file|
      if (file.has_key?('language') && file['language'] == language) || file['type'] == 'graph'
        path = file['path'] rescue ''
        unless path.empty?
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