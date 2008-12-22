class Hebmain::Widgets::Newsletter < WidgetManager::Base
  
  def render_sidebar
		div(:class => 'newsletter'){
			h1 'הרשמו לניוזלטר השבועי'
			form(:class => 'inner', :action => 'http://mlist.kbb1.com/subscribe/subscribe', :method => "get"){
				p{
					input :type => 'text', :id => 'ml_user_email', :name => 'email', :onfocus => "if(document.getElementById('ml_user_email').value == 'הזינו דואר אלקטרוני') { document.getElementById('ml_user_email').value = ''; }", :title => 'כתובת e-mail', :value => 'הזינו דואר אלקטרוני'
				  input :name => 'id', :type => 'hidden', :value => '161'
				  input :type => 'hidden', :name => 'name', :value => 'hebrew'
				  br
				  br
					input :name => "subscribe", :class => "button", :value => "הרשם", :type => "submit", :title => "הרשם", :alt => "הרשם" 
					input :type => "hidden", :name => "list", :value => "kabbalah" 
					input :type => "hidden", :name => "confirm", :value => "none" 
				}
			}
		}
  end
  
  def render_full
    w_class('cms_actions').new(:tree_node => tree_node, :options => {:buttons => %W{ delete_button  edit_button }, :position => 'bottom'}).render_to(doc)
    
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
