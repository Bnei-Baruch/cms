class Hebmain::Widgets::CampusForm < WidgetManager::Base
	 
	    
	def render_full
		 w_class('cms_actions').new(:tree_node => tree_node, :options => {:buttons => %W{ delete_button }, :position => 'bottom'}).render_to(doc) 
		 
		# make a form that is sending with get protocol info to itself & creating a new object
		# if user -> msg to say bravo
		# if admin -> show me all the users in the system
		
	    if tree_node.can_edit?
	    	campus_admin_mode
    	else 
				campus_user_mode
    	end
    	
	end
	
	def render_new_student
		if captcha_pass? @options[:session_id], @options[:captcha_input]
  		  create_student
  		else	
  		  div(:class => 'error'){text '‫שגיאה בהזנת הקוד המופיע בתמונה. אנא נסה שנית'}
  		  br
  		  campus_user_mode(@options[:name], @options[:email] ,@options[:tel])
  		end	
	end

	def create_student
		new_student = Student.new(:name => @options[:name], :telephone => @options[:tel], :email => @options[:email], :tree_node_id => @options[:tree_node_id], :adwords => @options[:adwords])
		new_student.save
		div(:class => 'success'){
		  text "הפרטים נתקבלו בהצלחה.‬"	
		}					
		javascript{
		rawtext 'alert("הפרטים נתקבלו בהצלחה.‬");'
		}
	end
	
	
	def campus_admin_mode
		div(:class => 'campus') {
	    	  text 'אדמין'
	    	  br
	    	  table{
	    	  tr(:class => 'title'){
	    	  	td{text 'שם'}
	    	  	td{text 'טל'}
	    	  	td{text 'אימייל'}
	    	  	td{text 'קמפיין'}
	    	  }
	    	  students_list = Student.list_all_students	    	  
	    	  students_list.each { |sl|
	    	  	tr{
	    	  		td {text sl.name }
	    	  		td {text sl.telephone}
	    	  		td {text sl.email}
	    	  		td {text sl.adwords}
	    	  	} #end of table line	
    	  } #end of list
    	  }#end of table
    	}
	
		
	end
	
	def campus_user_mode(def_name = '', def_email='', def_tel='')
			
		if defined? params[:adwords]
			def_adwords = params[:adwords]
		else
			def_adwords = ''
		end
		
		div(:class => 'campus'){
	    	 	div(:id => 'output2'){
		 			form(:id => 'myForm2'){
	    	 		   #user fields
	    	 		   span(:class => 'label') {text "שם : "}
     				   input :type => 'text', :name => 'options[name]', :value => def_name, :size => '31', :class => 'text'
     				   br
     				   span(:class => 'label') {text "אימייל : "}
     				   input :type => 'text', :name => 'options[email]', :value => def_email, :size => '31', :class => 'text'
     				   br
     				   span(:class => 'label') {text "טל : "}
     				   input :type => 'text', :name => 'options[tel]', :value => def_tel, :size => '31', :class => 'text'
     				   
     				   #hidden fields
     				   input :type => 'hidden', :name => 'options[widget_node_id]', :value => tree_node.id
     				   input :type => 'hidden', :name => 'node', :value => tree_node.id
     				   input :type => 'hidden', :name => 'options[tree_node_id]', :value => tree_node.id
     				   input :type => 'hidden', :name => 'options[new_student]', :value => 'true'
     				   input :type => 'hidden', :name => 'options[widget]', :value => 'campus_form'
     				   input :type => 'hidden', :name => 'view_mode', :value => 'new_student'
     				   input :type => 'hidden', :name => 'options[adwords]', :value => def_adwords
     				   br
     				   
     				#  captcha
     				  
					  session_id = rand(10_000)
					  div(:class => 'label_captcha') {text "אבטחת הרשמה :"}
  					  img :src => "http://captchator.com/captcha/image/"+session_id.to_s 
  					  br
     				  input :name => 'options[session_id]', :type => 'hidden', :value => session_id
     				  div(:class => 'label_captcha') {text "הקלידו את הכיתוב המופיע בתיבה: "}
   					  input  :name => 'options[captcha_input]', :type => 'text', :size => '10', :class => 'text'
					  

     				   
     				   #submit
     				   br
     				   input :type => 'submit', :name => 'Submit', :class => 'submit', :value => 'שלח'
     				   
				}
		  }
	  }
	end
	
	
	def captcha_pass?(session, answer)	
  	  session = session.to_i
  	  answer  = answer.gsub(/\W/, '')
  	  res = Net::HTTP.get_response(URI.parse("http://captchator.com/captcha/check_answer/#{session}/#{answer}"))
  	  if res.body == '1'
  	  	return true
  	  else
  	  	return false
  	  end
	end

	
end
