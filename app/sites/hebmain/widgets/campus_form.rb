class Hebmain::Widgets::CampusForm < WidgetManager::Base
	 require 'parsedate'
   require 'net/smtp'

	 include ParseDate
  
	def render_full
		 w_class('cms_actions').new(:tree_node => tree_node, :options => {:buttons => %W{ delete_button edit_button}, :position => 'bottom'}).render_to(doc) 
		 
		# make a form that is sending with get protocol info to itself & creating a new object
		# if user -> msg to say bravo
		# if admin -> show me all the users in the system
      rawtext get_description
	    if tree_node.can_edit?
	    	campus_admin_mode
    	else 
				campus_user_mode
    	end
	end
	
	def render_new_student
		if validate_captcha(@options[:captcha_value], @options[:captcha_index])
		 create_student
		else
			 div(:class => 'error'){text '‫שגיאה בהזנת הקוד המופיע בתמונה. אנא נסה שנית'}
			 br
		   campus_user_mode(@options[:name], @options[:email], @options[:tel])
		end
	end
		
	def create_student
    mail_from = get_email_from
    mail_to = get_email_to
    mail_subject = get_text_email
    mail_body = get_text_conf
    mail_do_not_send = get_do_not_send
    mail_conf =  @options[:email]
    mail_list_name = get_list_name
		new_student = Student.new(:name => @options[:name], :telephone => @options[:tel], :email => @options[:email], :tree_node_id => @options[:tree_node_id], :adwords => @options[:adwords], :listname => @options[:listname])
		new_student.save
    mail = Notifier.create_contact(mail_conf, mail_from, mail_subject, mail_body)
    mail.set_content_type("text/html")
    Notifier.deliver(mail) unless mail_do_not_send 
    send_student_by_mail(@options[:name],@options[:email],@options[:tel], mail_from, mail_to, mail_list_name)
		div(:class => 'success'){
		  text "הפרטים נתקבלו בהצלחה.‬"	
		}
		javascript{
    	rawtext 'alert("הפרטים נתקבלו בהצלחה.‬");'
		}
	end
	
  def send_student_by_mail(name = '' , email = '', tel = '', mailfrom = 'campus@kab.co.il', mailto = 'info@kab.co.il', mail_list_name = 'campus')
    msg = <<EOF
From: #{mailfrom}
Content-Type: text/plain; charset=utf-8
Subject: You have a new registration

New registration to the #{mail_list_name} list

Name: #{name}
Email: #{email}
Tel: #{tel}


EOF
    msg
    begin
    #Net::SMTP.start("smtp.kabbalah.info", 25, 'kbb1.com','yaakov','pass', :plain ) { |smtp|
    Net::SMTP.start("localhost", 25) { |smtp|
      smtp.sendmail msg, mailfrom, [mailto]
    }
    rescue 
      #the email have not been send, but student is in database
    end
  end
  
 
	def campus_admin_mode
		div(:class => 'campus') {
	    	  text 'אדמין'
	    	  br
	    	  table{
	    	  tr(:class => 'title'){
	    	  	td{text 'תאריך'}
	    	  	td{text 'שם'}
	    	  	td{text 'טל'}
	    	  	td{text 'אימייל'}
	    	  	td{text 'קמפיין'}
            td{text 'שם הרשימה'}
	    	  }
          if get_list_name == "" 
            students_list = Student.list_all_students	    	  
          else
            students_list = Student.list_all_students_for_list(get_list_name)
          end
	    	  students_list.each { |sl|
	    	    stcreated = parsedate sl.created_at.to_s	  	
	    	  	tr{
	    	  		td {text "#{stcreated[0]}/#{stcreated[1]}/#{stcreated[2]}"}
	    	  		td {text sl.name }
	    	  		td {text sl.telephone}
	    	  		td {text sl.email}
	    	  		td {text sl.adwords}
              td {text sl.listname}
	    	  	} #end of table line	
    	  } #end of list
    	  }#end of table
    	}
	end
	
	def campus_user_mode(def_name = '', def_email='', def_tel='')
    
    field_1_label = get_campus_label_1
    field_1_must = get_campus_label_1_is_mandatory
    field_1_hide = get_campus_hide_label_1
    
    field_2_label = get_campus_label_2
    field_2_must = get_campus_label_2_is_mandatory
    field_2_hide = get_campus_hide_label_2
    
    field_3_label = get_campus_label_3
    field_3_must = get_campus_label_3_is_mandatory
    field_3_hide = get_campus_hide_label_3
    
    
    #if user was clever enought to hide all the field - just leave - stupid!
    if field_1_hide && field_2_hide && field_3_hide
      return
    end
    
    #if field is hidden - it can't be mandatory - sorry
    if field_1_hide
      field_1_must = false
    end
    
    if field_2_hide
      field_2_must = false
    end
  
    if field_3_hide
      field_3_must = false
    end
    
    #if label are empty - keep original label the form was built for
    if field_1_label == ""
      field_1_label = "שם"
    end
    
    if field_2_label == ""
      field_2_label = "דוא''ל"
    end
    
    if field_3_label == ""
      field_3_label = "טלפון"
    end
    
    #if label are mandatory - add a nice star next to it
    if field_1_must
      field_1_label = field_1_label + "<span class='mandatory'>*</span>"
    end
    if field_2_must
      field_2_label = field_2_label + "<span class='mandatory'>*</span>"
    end
    if field_2_must
      field_2_label = field_2_label + "<span class='mandatory'>*</span>"
    end
    
    # if campaign
		if params.include?(:adwords)
			def_adwords = params[:adwords]
		else
			def_adwords = ''
		end
    
    
		div(:class => 'campus'){
	    	 	div(:id => 'output2'){
		 			form(:id => 'myForm2'){
	    	 		   #user fields
                p{
                
                unless field_1_hide
                  span(:class => 'label') {text field_1_label+ " : "}
                  input :type => 'text', :name => 'options[name]', :value => def_name, :size => '31', :class => 'text'
                  br
                end

                unless field_2_hide
                  span(:class => 'label') {text field_2_label+" : "}
                  input :type => 'text', :name => 'options[email]', :value => def_email, :size => '31', :class => 'text'
                  br
                end
                
                unless field_3_hide
                  span(:class => 'label') {text field_3_label+" : "}
                  input :type => 'text', :name => 'options[tel]', :value => def_tel, :size => '31', :class => 'text'
                end

                div(:class => 'label_captcha'){text "אבטחת הרשמה :"}
                captcha_index = rand(11)
                img :src => generate_captcha(captcha_index)[0] , :class => 'img_captcha', :alt => 'captcha'
                br
                div(:class => 'label_captcha') {text "הקלידו את הכיתוב המופיע בתיבה: "}
                input :type => 'text', :name => 'options[captcha_value]', :size => '31', :class => 'text'
                input :type => 'hidden', :name => 'options[captcha_index]', :value => captcha_index	

                input :type => 'hidden', :name => 'options[widget_node_id]', :value => tree_node.id
                input :type => 'hidden', :name => 'node', :value => tree_node.id
                input :type => 'hidden', :name => 'options[tree_node_id]', :value => tree_node.id
                input :type => 'hidden', :name => 'options[new_student]', :value => 'true'
                input :type => 'hidden', :name => 'options[widget]', :value => 'campus_form'
                input :type => 'hidden', :name => 'view_mode', :value => 'new_student'
                input :type => 'hidden', :name => 'options[adwords]', :value => def_adwords
                input :type => 'hidden', :name => 'options[listname]', :value => get_list_name

                #submit
                br
                input :type => 'submit', :name => 'Submit', :class => 'submit', :value => 'שלח'
                br
              }
				}
		  }
	  }
	end
	

	def generate_captcha(index = 0)
		captcha_array = get_captcha_array
		return captcha_array[index]
	end
	
	def validate_captcha(textvalue, index)		
		captcha_array = get_captcha_array
		if(textvalue == captcha_array[index.to_i][1])
			return true
		end			
	end
	
	def get_captcha_array
		captcha_array = Array.new
		captcha_array[0] = Array.new
		captcha_array[0][0] = '../../jcap/cimg/1.jpg'
		captcha_array[0][1] = 'polish'
		
		captcha_array[1] = Array.new
		captcha_array[1][0] = '../../jcap/cimg/2.jpg'
		captcha_array[1][1] = 'past'
		
		captcha_array[2] = Array.new
		captcha_array[2][0] = '../../jcap/cimg/3.jpg'
		captcha_array[2][1] = 'again'

		captcha_array[3] = Array.new
		captcha_array[3][0] = '../../jcap/cimg/4.jpg'
		captcha_array[3][1] = 'when'
		
		captcha_array[4] = Array.new
		captcha_array[4][0] = '../../jcap/cimg/5.jpg'
		captcha_array[4][1] = 'birth'
		
		captcha_array[5] = Array.new
		captcha_array[5][0] = '../../jcap/cimg/6.jpg'
		captcha_array[5][1] = 'crime'		
		
		captcha_array[6] = Array.new
		captcha_array[6][0] = '../../jcap/cimg/7.jpg'
		captcha_array[6][1] = 'square'
		
		captcha_array[7] = Array.new
		captcha_array[7][0] = '../../jcap/cimg/8.jpg'
		captcha_array[7][1] = 'expert'
	
		captcha_array[8] = Array.new
		captcha_array[8][0] = '../../jcap/cimg/9.jpg'
		captcha_array[8][1] = 'rule'
		
		captcha_array[9] = Array.new
		captcha_array[9][0] = '../../jcap/cimg/10.jpg'
		captcha_array[9][1] = 'degree'
		
		captcha_array[10] = Array.new
		captcha_array[10][0] = '../../jcap/cimg/11.jpg'
		captcha_array[10][1] = 'linen'
		
		captcha_array[11] = Array.new
		captcha_array[11][0] = '../../jcap/cimg/12.jpg'
		captcha_array[11][1] = 'pocket'
		
		return captcha_array
	end
	
end
