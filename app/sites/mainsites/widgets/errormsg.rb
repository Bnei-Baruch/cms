class Mainsites::Widgets::Errormsg < WidgetManager::Base
  def render_full
    w_class('cms_actions').new( :tree_node => tree_node,
      :options => {:buttons => %W{ edit_button delete_button },
        :resource_types => %W{ errormsg },
        :new_text => 'צור יחידת תוכן חדשה',
        :has_url => false
      }).render_to(self)
    div(:class => "errormsg"){
      img(:src => "/images/hebmain/err/error404_03.jpg", :class => "corner1")
      img(:src => "/images/hebmain/err/error404_05.jpg", :class => "corner2")
      img(:src => "/images/hebmain/err/error404_10.jpg", :class => "cross")
      img(:src => "/images/hebmain/err/error404_13.jpg", :class => "corner4")
      img(:src => "/images/hebmain/err/error404_14.jpg", :class => "corner3")
      span(:class => "title"){text get_title}
      span(:class => "errnum"){text _(:error404)}
      javascript{
        rawtext <<-GA
          google_tracker("/Error404");
        GA
      }
    }
  end
end
