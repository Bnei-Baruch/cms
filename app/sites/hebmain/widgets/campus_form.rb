class Hebmain::Widgets::CampusForm < WidgetManager::Base
  require 'parsedate'
  require 'net/smtp'

  include ParseDate
  
	def render_full
    #@presenter.disable_cache
    w_class('cms_actions').new(:tree_node => tree_node, :options => {:buttons => %W{ delete_button edit_button}, :position => 'bottom'}).render_to(self)
		 
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
    #@presenter.disable_cache
		if validate_captcha(@options[:captcha_value], @options[:captcha_index])
      create_student
		else
      campus_user_mode(@options[:name], @options[:email], @options[:tel], true)
		end
	end
  
  def render_captcha
    captcha_index = rand(11)
    input :type => 'hidden', :name => 'options[captcha_index]', :value => captcha_index	
    img :src => generate_captcha(captcha_index)[0] , :class => 'img_captcha', :alt => 'captcha'
  end
		
	def create_student
	  
	  track_string = get_track_string
    mail_from = get_email_from
    mail_to = get_email_to
    mail_subject = get_text_email
    mail_body = get_text_conf
    mail_do_not_send = get_do_not_send
    mail_conf =  @options[:email]
    mail_list_name = get_list_name
		new_student = Student.new(:name => @options[:name], :telephone => @options[:tel], :email => @options[:email], :tree_node_id => @options[:tree_node_id], :adwords => @options[:adwords], :listname => @options[:listname])
		new_student.save
#    mail = Notifier.create_contact(mail_conf, mail_from, mail_subject, mail_body)
#    mail.set_content_type("text", "html", {"charset" => 'utf-8'})
    Notifier.deliver_student(mail_conf, mail_from, mail_subject, mail_body) unless mail_do_not_send
    send_student_by_mail(@options[:name],@options[:email],@options[:tel], mail_from, mail_to, mail_list_name)
		div(:class => 'success'){
		  text "הפרטים נתקבלו בהצלחה.‬"	
		}

    track_string = get_track_string
    unless track_string == ""
      str_track = track_string.split('***')
      str_track0 = str_track[0]
      str_track1 = str_track[1]
      #todo : tikun tirgum le javascript
      javascript {
        rawtext <<-track
           google_tracker('#{str_track1}');
           alert("#{_(:'details_saved_successfully')}");
        track
      }
      img :height => "1", :width => "1", :border => "0", :src => str_track0
    end    
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
    begin
      Net::SMTP.start("localhost", 25) { |smtp|
        smtp.sendmail msg, mailfrom, [mailto]
      }
    rescue 
      #the email have not been send, but student is in database
    end
  end
  
 
	def campus_admin_mode
    div(:class => 'courses'){
      link_to 'Listing of Courses', admin_courses_path
    }
    br
		div(:class => 'campus') {
      #  text 'אדמין'
      text _(:'admin')
      br
      table{
        tr(:class => 'title'){
          td{text _(:'date')}
          td{text _(:'name')}
          td{text _(:'tel')}
          td{text _(:'email')}
          td{text _(:'campaign')}
          td{text _(:'list_name')}
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
	
	def campus_user_mode(def_name = '', def_email='', def_tel='', with_error = false)

    field_1_label = get_campus_label_1
    field_1_must = get_campus_label_1_is_mandatory
    field_1_hide = get_campus_hide_label_1
    
    field_2_label = get_campus_label_2
    field_2_must = get_campus_label_2_is_mandatory
    field_2_hide = get_campus_hide_label_2
    
    field_3_label = get_campus_label_3
    field_3_must = get_campus_label_3_is_mandatory
    field_3_hide = get_campus_hide_label_3
    

    #if user was clever enough to hide all the field - just leave - stupid!
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
      field_1_label = _(:'name')
    end
    
    if field_2_label == ""
      field_2_label = _(:'email')
    end
    
    if field_3_label == ""
      field_3_label = _(:'tel')
    end
    
    #if label are mandatory - add a nice star next to it
    if field_1_must
      field_1_label = field_1_label + "<span class='mandatory'>&nbsp;*</span>"
    end
    if field_2_must
      field_2_label = field_2_label + "<span class='mandatory'>&nbsp;*</span>"
    end
    if field_3_must
      field_3_label = field_3_label + "<span class='mandatory'>&nbsp;*</span>"
    end
    
    # if campaign
    if @presenter.page_params.member?(:adwords)
      def_adwords = @presenter.page_params[:adwords]
    else
      def_adwords = ''
    end
    
    if get_centered
      id_centered = 'position_center'
    end

    (@locations, @courses) = Course.prepare_locations
    with_buttons = get_enable_payment && @locations.size > 0
    
    unless with_error
      javascript{
        rawtext 'function loadCaptcha(){'
        rawtext "$('.campus_captcha').load('#{get_page_url(@presenter.node)}', {view_mode:'captcha', 'options[widget]':'campus_form','options[widget_node_id]':#{tree_node.id}})"
        rawtext '}'
      }
    end

		div(:class => 'campus', :id => id_centered){
      div(:id => 'output2'){
        if with_error
          div(:class => 'error'){text _(:'error_mesg')}
          br
        end
        if with_buttons
          form(:id => 'myForm3', :action => 'http://events.kabbalah.info/campus/register.php', :method => 'POST'){
            p
            input :type => 'hidden', :id => 'location', :name => 'location', :value => ''
            input :type => 'hidden', :id => 'dates', :name => 'dates', :value => ''
            input :type => 'hidden', :id => 'name', :name => 'name', :value => ''
            text 'בחר את הסניף הרצוי: '
            # select city
            select(:name => 'location', :id => 'location'){
              option '----------'
              @locations.each{ |l|
                option l
              }
            }
            br
            br
            @locations.each{|location|
              table(:id => "#{location.gsub(/\s|"|'/, '-')}", :class => 'courses', :style => 'display: none;') {
                tr {
                  th { rawtext 'סניף' }
                  th { rawtext 'תאריכים' }
                  th { rawtext 'בחר קורס' }
                }

                @courses[location].each{ |c|
                  start_date = DateTime.strptime(c.start_date, '%Y-%M-%d').strftime('%d/%M/%Y')
                  end_date = DateTime.strptime(c.end_date, '%Y-%M-%d').strftime('%d/%M/%Y')
                  location = c.location.escape_javascript
                  name = c.name.escape_javascript
                  warning = c.warning.empty? ? nil : c.warning.escape_javascript
                  tr {
                    td { rawtext location }
                    td { rawtext "מ-#{start_date} עד #{end_date}" }
                    td do
                      dates = "#{c.start_date} - #{c.end_date}"
                      link_to "#{c.name}", "#",
                      :onclick => "submit_course('#{location}', '#{dates}', '#{name}', '#{warning}', this); return false;"
                    end
                  }
                }
              }
            }
            p
          }
        else
          form(:id => 'myForm2'){
            #user fields
            p{
              unless field_1_hide
                span(:class => 'label') {rawtext field_1_label+ " : "}
                input :type => 'text', :name => 'options[name]', :value => def_name, :size => '31', :class => 'text'
                br
              end

              unless field_2_hide
                span(:class => 'label') {rawtext field_2_label+" : "}
                input :type => 'text', :name => 'options[email]', :value => def_email, :size => '31', :class => 'text'
                br
              end

              unless field_3_hide
                span(:class => 'label') {text field_3_label+" : "}
                input :type => 'text', :name => 'options[tel]', :value => def_tel, :size => '31', :class => 'text'
              end

              p(:style => 'font-size:11px;'){
                rawtext 'אני רוצה לקבל מכם דיוור מעת לעת. לעולם לא נשתמש בפרטיך ולא נמכור או אשכיר אותם לכל גוף אחר. הם יישארו חסויים אצלנו, ובכל שלב תוכל לצאת מרשימת התפוצה שלנו.'
              }
              
              div(:class => 'label_captcha'){text _(:'label_captcha')+':'}

              div(:class => 'campus_captcha')
              div(:class => 'label_captcha') {text _(:'label_captcha2')+':'}
              input :type => 'text', :name => 'options[captcha_value]', :size => '31', :class => 'text'


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
        end
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
