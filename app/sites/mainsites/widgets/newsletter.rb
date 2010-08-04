class Mainsites::Widgets::Newsletter < WidgetManager::Base
  
  # Newsletter subscription form belongs to section/homepage, not to a specific page.
  # Hence we have to look for the first ancestor that is also section.
  # In case this ancestor have no subscription form we have to try homepage.
  def render_sidebar
    site_settings = $config_manager.site_settings(@presenter.website.hrid)[:newsletters] rescue return
    return if site_settings.empty?

    sections = @presenter.main_sections & (tree_node.ancestors + [tree_node])
    if sections.empty?
      # Homepage
      nl = site_settings
    else
      # From section or from website
      nl = site_settings[sections[0].id] || site_settings
    end

    # No newsletter definition on any level
    nl = site_settings if nl.empty?

    icon = nl[:icon] || site_settings[:icon]
    box_title = nl[:box_title] || site_settings[:box_title]
    action = nl[:action] || site_settings[:action]
    method = nl[:method] || site_settings[:method]
    tracker = nl[:tracker] || site_settings[:tracker]
    box_text_button = nl[:box_text_button] || site_settings[:box_text_button]
    input_box_text = nl[:input_box_text] || site_settings[:input_box_text]
    style = nl[:style] || site_settings[:style]
    subtitle = nl[:subtitle] || site_settings[:subtitle]

		div(:class => 'newsletter'){
      #      image = get_image
      icon = "/images/#{@presenter.website.hrid}/#{icon}"
      div(:class => 'h1_div'){
        div(:class => 'h1'){text box_title }
        div(:class => 'subtitle'){ text subtitle }if subtitle
      }

			form(:class => 'inner', :action => action, :method => method,
        :onsubmit => "javacript:google_tracker('#{tracker}');"){
				p{
					input :type => 'text', :id => 'ml_user_email', :name => 'YMP2',
          :onfocus => "if(document.getElementById('ml_user_email').value == '#{input_box_text}') { document.getElementById('ml_user_email').value = ''; }",
          :title => _(:email_address), :value => input_box_text
				  input :name => 'YMP0', :type => 'hidden', :value => ''
				  br
				  br
          span :class => 'prebutton', :style => 'display:block'
					input :name => "subscribe", :class => "button", :value => box_text_button, :type => "submit",
          :title => box_text_button, :alt => box_text_button, :onclick => 'return validateNewsletterEmail();'
          span :class => 'postbutton', :style => 'display:block'
          span :class => 'clear', :style => 'display:block'
				}
			}
		}
  end

  def render_full
    site_settings = $config_manager.site_settings(@presenter.website.hrid)[:newsletters] rescue return
    return if site_settings.empty?

    sections = @presenter.main_sections & (tree_node.ancestors + [tree_node])
    if sections.empty?
      nl = site_settings[:website]
    else
      nl = site_settings[sections[0].id]
    end

    return if nl.empty?

    #    if tree_node == section
    w_class('cms_actions').new(:tree_node => tree_node, :options => {:buttons => %W{ delete_button  edit_button }, :position => 'bottom'}).render_to(self)
    #    end
    
    box_title = get_title || _(:newsletter_subscription)
    box_name = get_name
    action = get_id || 'http://ymlp.com/subscribe.php?YMLPID=gbbwwygmgeh' # to move to configuration
    box_text_button = get_text_button || 'שלח'
    input_box_text = get_input_box_text || nl[:enter_email]
    
    #    if action.empty?
    #      # If there is no action we have to look for the section of this node
    #      action = (!sections.empty? && sections[0].id == 3040) ? # Channel 66
    #      'http://ymlp.com/subscribe.php?YMLPID=gbbwwygmgee' :
    #        'http://ymlp.com/subscribe.php?YMLPID=gbbwwygmgeh'
    #    end

    div(:class => 'newsletter', :id => 'newsletter_width'){
      h1 box_title
      form(:class => 'inner', :action => action, :method => "post",
        # To replace 'hebrew' with sections' name
        :onsubmit => "javacript:google_tracker('/homepage/widget/newsletter/hebrew');"){
        p{
          text box_name + ' : ' unless box_name.empty?
          input :type => 'hidden', :name => 'YMP0', :value => ''
          input :type => 'text', :id => 'ml_user_email', :name => 'YMP2',
          :onfocus => "if(document.getElementById('ml_user_email').value == '#{input_box_text}') { document.getElementById('ml_user_email').value = ''; }",
          :title => input_box_text, :value => input_box_text
          br
          br
          span :class => 'prebutton', :style => 'display:block'
          input :name => "subscribe", :class => "button", :value => box_text_button, :type => "submit",
          :title => box_text_button, :alt => box_text_button, :onclick => 'return validateNewsletterEmail();'
          span :class => 'postbutton', :style => 'display:block'
          span :class => 'clear', :style => 'display:block'
        }
      }
    }
  end
  
  def render_middle
    box_title = get_title
    box_name = get_name
    box_id = get_id
    box_text_button = get_text_button
    input_box_text = get_input_box_text
    
    if box_text_button == ""
      box_text_button = 'שלח'
    end
    
    div(:class => 'newsletter', :id => 'newsletter_width'){
      h1 box_title
      form(:class => 'inner', :action => 'http://mlist.kbb1.com/subscribe/subscribe', :method => "get"){
        p{
          text input_box_text +" : "
          input :type => 'text', :id => 'email', :name => 'email' #, :onfocus =>  "if(document.getElementById('email').value == 'הזן כתובת e-mail') { document.getElementById('email').value = ''; }", :title => 'כתובת e-mail', :value => 'הזן כתובת e-mail'
          input :type => 'hidden', :name => 'id', :value => box_id
          input :type => 'hidden', :name => 'name', :value => box_name
          br
          br
          input :name => "subscribe", :class => "button", :value => box_text_button , :type => "submit", :title => box_text_button, :alt => box_text_button
        }
      }
    }
  end

end
