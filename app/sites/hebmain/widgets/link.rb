class Hebmain::Widgets::Link < WidgetManager::Base
  
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
      a({:href => get_url, :title => get_alt, :target => get_open_in_new_window ? '_blank' : 'self' }.merge!(gg_analytics_tracking(get_name))) {
        img(:src => img_path('link.gif'), :alt => '') 
        text get_name
      }
    end
  end
  
  def gg_analytics_tracking (name_of_link = '')
    if presenter.is_homepage? 
	  {:onclick => "javascript:urchinTracker('/homepage/outgoing/#{name_of_link}');"}
  	else
  	  {}
  	end
  end
end
