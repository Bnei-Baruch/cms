class Hebmain::Widgets::ContentPage < WidgetManager::Base

  def render_large
    @image_src = get_preview_image(:image_name => 'large')
    show_content_page(false)  #### - disabled by Dudi's request
  end

  def render_medium
    @image_src = get_preview_image(:image_name => 'medium')
    show_content_page(false)  #### - disabled by Dudi's request
  end

  def render_small
    @image_src = get_preview_image(:image_name => 'small')
    show_content_page(false)
  end

  def show_content_page(display_h2 = true)
    main_tree_node = tree_node.resource.tree_nodes.main
    url = get_page_url(main_tree_node)
    w_class('cms_actions').new(:tree_node => tree_node, :options => {:buttons => %W{ delete_button edit_button }, :position => 'bottom'}).render_to(doc)
    if @image_src
      a(:href => url){
        img(:class => 'img', :src => @image_src, :alt => get_preview_image_alt, :title => get_preview_image_alt) 
      }
    end
    preview_title = get_preview_title rescue ''
    large_title = get_title rescue ''
    
    final_title = !preview_title.empty? ? preview_title : (!large_title.empty? ? large_title : '')
    unless final_title.empty?
      h1{
        a final_title, :href => url
      }
    end
    h2 get_small_title if display_h2 && !get_small_title.empty?
    div(:class => 'descr') { text get_description } unless get_description.empty?
    
    unless presenter.site_settings[:use_advanced_read_more]
      a(:class => 'more', :href => url) { text "לכתבה המלאה" }
    else
      is_video, is_audio, is_article = is_video_audio_article
      if is_article
        if !is_video && !is_audio
          a(:class => 'more', :href => url) { text "לכתבה המלאה" }
        else
          a(:class => 'more', :href => url) { 
            text "לכתבה המלאה"
            img(:class => 'img', :src => img_path('video.png'), :alt => '') if is_video
            img(:class => 'img', :src => img_path('audio.png'), :alt => '') if is_audio
          }
        end
      else # no article
        if is_video || is_audio
          a(:class => 'more', :href => url) { 
            if is_video
              span{text 'לצפייה'}
            else
              span{text 'להאזנה'}
            end
            img(:class => 'img', :src => img_path('video.png'), :alt => '') if is_video
            img(:class => 'img', :src => img_path('audio.png'), :alt => '') if is_audio
          }
        end
      end
    end
  end

  def is_video_audio_article
    tree_nodes = TreeNode.get_subtree(
      :parent => tree_node.main.id, 
      :resource_type_hrids => ['video', 'article', 'audio'], 
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
      when 'article'
        is_article = true
      end
      if is_video && is_audio && is_article
        return true, true, true
      end
    }
    
    return is_video, is_audio, is_article
  end
  
end
