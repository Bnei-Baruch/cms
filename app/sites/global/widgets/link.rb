class Global::Widgets::Link < WidgetManager::Base

  def render_full
    w_class('cms_actions').new(:tree_node => @tree_node,
      :options => {:buttons => %W{ edit_button delete_button },
        :mode => 'inline',
        :resource_types => %W{ link }}).render_to(self)
        
    if resource
      a({:href => get_url, :title => get_alt}.merge!(gg_analytics_tracking(get_name))) {
        text get_name
      }
    end
  end

  def render_new_window
    w_class('cms_actions').new(:tree_node => @tree_node,
      :options => {:buttons => %W{ edit_button delete_button },
        :mode => 'inline',
        :resource_types => %W{ link }}).render_to(self)

    if resource
      a({:href => get_url, :class => get_open_in_new_window ? 'target_blank' : 'target_self', :title => get_alt}.merge!(gg_analytics_tracking(get_name))) {
        text get_name
      }
    end
  end

  def render_language_option
    option(:value => get_url){rawtext get_title}
  end

  def render_language_link
    a(:href => get_url){rawtext get_title}
  end

  def render_with_image
    if resource
      w_class('cms_actions').new(:tree_node => @tree_node,
        :options => {:buttons => %W{ edit_button delete_button },
          :mode => 'inline',
          :resource_types => %W{ link }}).render_to(self)
      image = get_icon
      a({:href => get_url, :title => get_alt, :class => get_open_in_new_window ? 'target_blank' : 'target_self' }.merge!(gg_analytics_tracking(get_name))) {
        img(:src => image, :alt => '') unless image.blank?
        br
        text get_name
      }
    end
  end
  
  def gg_analytics_tracking (name_of_link = '')
    if presenter.is_homepage? 
      {:onclick => "javascript:google_tracker('/homepage/outgoing/#{name_of_link}');"}
    else
      {}
    end
  end
end
