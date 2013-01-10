class Mainsites::Widgets::ContentPage < WidgetManager::Base

  def render_large
    @image_src, @image_dims = get_preview_image(:image_name => 'large', :with_dimensions => true)
    show_content_page(false)  #### - disabled by Dudi's request
  end

  def render_medium
    @image_src, @image_dims = get_preview_image(:image_name => 'medium', :with_dimensions => true)
    show_content_page(false)  #### - disabled by Dudi's request
  end

  def render_small
    @image_src, @image_dims = get_preview_image(:image_name => 'small', :with_dimensions => true)
    show_content_page(false)
  end

  def gg_analytics_tracking (name_of_link = '')
    if presenter.is_homepage? 
      {:onclick => "javascript:google_tracker('/homepage/#{name_of_link}');"}
    else
      {}
    end
  end

  def show_content_page(display_h2 = true)
    main_tree_node = tree_node.resource.tree_nodes.main
    url = get_page_url(main_tree_node)
    url_name = url.split('/').reverse[0]
    w_class('cms_actions').new(:tree_node => tree_node, :options => {:buttons => %W{ delete_button edit_button }, :position => 'bottom'}).render_to(self)
    if @image_src
      a({:href => url}.merge!(gg_analytics_tracking(url_name))){
        img(:class => 'img', :src => @image_src, :alt => get_preview_image_alt, :title => get_preview_image_alt)
      }
    end
    preview_title = get_preview_title rescue ''
    large_title = get_title rescue ''
    
    final_title = !preview_title.empty? ? preview_title : (!large_title.empty? ? large_title : '')
    unless final_title.empty?
      h2{
        a({:href => url}.merge!(gg_analytics_tracking(url_name))) {
    	  text final_title
        } 
      }
    end
    h2 get_small_title if display_h2 && !get_small_title.empty?
    div(:class => 'descr') { text get_description } unless get_description.empty?

    link_title = get_link_title
    link_title = nil if link_title.nil? || link_title.empty?
    klass = @image_src ? 'more' : 'more_no_img'
    unless presenter.site_settings[:use_advanced_read_more]
      a({:class => klass, :href => url}.merge!(gg_analytics_tracking(url_name))) { text _(:read_more) }
    else
      is_video, is_audio, is_article = is_video_audio_article
      if is_article
        a({:class => klass, :href => url}.merge!(gg_analytics_tracking(url_name))) { 
          text link_title ? link_title : _(:tofullpage)
          img(:src => img_path('video.png'), :alt => '') if is_video
          img(:src => img_path('audio.png'), :alt => '') if is_audio
          img(:src => img_path('empty.gif'), :alt => '', :class => 'empty-gif') if !is_video && !is_audio
        }
        div(:class => "clear")
      else # not article
        if is_video || is_audio
          a({:class => klass, :href => url}.merge!(gg_analytics_tracking(url_name))) { 
            if is_video
              text = link_title ? link_title : _(:to_watch)
              image = 'video.png'
            else
              text = link_title ? link_title : _(:to_listen)
              image = 'audio.png'
            end
            span{text text}
            img(:src => img_path(image), :alt => '')
        }
        else
          a({:class => klass, :href => url}.merge!(gg_analytics_tracking(url_name))) {
            text link_title ? link_title : _(:read_more)
            img(:src => img_path('empty.gif'), :alt => '', :class => 'empty-gif')
          }
        end
        div(:class => 'clear')
      end
    end
  end

  def is_video_audio_article
    tree_nodes = TreeNode.get_subtree(
      :parent => tree_node.main.id, 
      :resource_type_hrids => ['video', 'article', 'audio', 'video_gallery', 'media_casting'],
      :depth => 1
    ) 
    is_article = !get_body.empty?
    is_audio = false
    is_video = false
    tree_nodes.each { |tree_node|
      case tree_node.resource.resource_type.hrid
      when 'audio'
        is_audio = true
      when 'video'
        is_video = true
      when 'video_gallery'
        is_video = true
      when 'article'
        is_article = true
      when 'media_casting'
        is_audio = true
      end
      if is_video && is_audio && is_article
        return true, true, true
      end
    }
    
    return is_video, is_audio, is_article
  end
  
end
