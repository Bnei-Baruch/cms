class Hebmain::Widgets::Newsletter < WidgetManager::Base
  
  def render_sidebar
		div(:class => 'newsletter'){
			h1 'הרשמה לגיליון האלקטרוני'
			form(:class => 'inner', :action => 'http://mlist.kbb1.com/subscribe/mult_subscribe_NC', :method => "get"){
				p{
					input :type => 'text', :id => 'ml_user_email', :name => 'ml_user[email]', :onfocus => "if(document.getElementById('ml_user_email').value == 'הזן כתובת e-mail') { document.getElementById('ml_user_email').value = ''; }", :title => 'כתובת e-mail', :value => 'הזן כתובת e-mail'
					input :name => 'ml_list_ids[]', :type => 'hidden', :value => '161'
				  input :name => "ml_list_ids[]", :type => "checkbox", :value => "175", :checked => 'checked', :class => "check"
				  
				  span(:class => "label"){
				  	text 'כן, אני מעוניין/ת לקבל סרטוני וידאו ישירות למייל'
				  }
				  br
					input :name => "subscribe", :class => "button", :value => "הרשם", :type => "submit", :title => "הרשם", :alt => "הרשם" 
					input :type => "hidden", :name => "Additional_", :value => "hebrew" 
					input :type => "hidden", :name => "list", :value => "kabbalah" 
					input :type => "hidden", :name => "demographics", :value => "Additional_"
					input :type => "hidden", :name => "confirm", :value => "none" 
				}
			}
		}
  end
  
  def render_full
    box_title = get_title
    box_name = get_name
    box_id = get_id
    box_text_button = get_text_button
    
    div(:class => 'newsletter'){
			h1 box_title
			form(:class => 'inner', :action => 'http://mlist.kbb1.com/subscribe/subscribe', :method => "get"){
				p{
					input :type => 'text', :id => 'email', :name => 'email', :onfocus =>  "if(document.getElementById('email').value == 'הזן כתובת e-mail') { document.getElementById('email').value = ''; }", :title => 'כתובת e-mail', :value => 'הזן כתובת e-mail'
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