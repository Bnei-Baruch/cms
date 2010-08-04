class Hebmain::Widgets::Link < Global::Widgets::Link #WidgetManager::Base
  
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

  def render_with_image
    if resource
      w_class('cms_actions').new(:tree_node => @tree_node,
        :options => {:buttons => %W{ edit_button delete_button },
          :mode => 'inline',
          :resource_types => %W{ link }}).render_to(self)
      a({:href => get_url, :title => get_alt, :class => get_open_in_new_window ? 'target_blank' : 'target_self' }.merge!(gg_analytics_tracking(get_name))) {
        img(:src => img_path('link.gif'), :alt => '', :style => 'width:16px;height:10px;margin:0 0 0 -1px;vertical-align:middle;')
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
