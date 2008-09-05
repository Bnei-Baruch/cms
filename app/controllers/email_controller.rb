class EmailController < ApplicationController
  require 'net/smtp'


  
  def send_node
    adresse_to = params[:adresseto]
    node_id = params[:id]
    adresse_from = params[:adressefrom]
    sender_name = params[:sender_name]
    receiver_name = params[:receiver_name]
    sendmode = params[:sendmode]
    
    if sendmode == "manpower"
      send_manpower(adresse_to, params)
      return
    end
    
    host = 'http://' + request.host
    prefix = params[:prefix]
    
    my_port = request.server_port.to_s
    portinurl = my_port == '80' ? '' : ':' + my_port
    
    url = host + portinurl + '/' + prefix + '/short/' + node_id
    
    send_mail(url, adresse_to, adresse_from, sender_name, receiver_name)
    redirect_to url
    
  end
  
  #def send_mail(email_dest = '', add_from = '', url = '')
  #def send_mail(url = '')
  def send_mail(url = '', adresse_to ='', adresse_from ='', sender_name = '', receiver_name = ''  )
    msg = <<EOF
From: #{adresse_from}
Content-Type: text/plain; charset=utf-8
Subject: שלום #{receiver_name} חברך #{sender_name} ממליץ לך על הלינק הזה

שלום #{receiver_name} חברך #{sender_name} ממליץ לך על הלינק הזה
#{url}

EOF
    msg # end of rawtext 
    Net::SMTP.start("smtp.kabbalah.info", 25,
                      'helodomain.com','yaakov','einodmilvado', :plain ) { |smtp|
      smtp.sendmail msg, adresse_from, [adresse_to]
    }

 end
 
  def send_manpower(adress_to ,params)
  firstname = params[:firstname]
  lastname  = params[:lastname]
  email = params[:email]
  mobilephone = params[:mobilephone]
  birthdate = params[:birthdate]
  mainphone = params[:mainphone]
  hometown = params[:hometown]
  firstlanguage = params[:firstlanguage]
  language1 = params[:language1]
  read1 = params[:read1]
  write1 = params[:write1]
  speak1 = params[:speak1]
  language2 = params[:language2]
  read2 = params[:read2]
  write2 = params[:write2]
  speak2 = params[:speak2]
  language3 = params[:language3]
  read3  = params[:read3]
  write3 = params[:write3]
  speak3 = params[:speak3]
  profession = params[:profession]
  time = params[:time]
  whelp = params[:whelp]
  
  firstname_label = _('First Name')
  lastname_label = _('Last Name')
  email_label = _('Email')
  birthdate_label = _('Year of Birth')
  mainphone_label = _('Main phone')
  mobilephone_label = _('Mobile Phone')
  hometown_label = _('Hometown')
  firstlanguage_label = _('First Language')
  languages_label = _('Knowledge of languages')
  profession_label = _('Profession')
  time_label = _('Free Time')
  whelp_label = _('Where do you want to help?')
    
     msg = <<EOF
From: manpowerform@kab.co.il
Content-Type: text/plain; charset=utf-8
Subject:Manpower

#{firstname_label} :
#{firstname}

#{lastname_label}:
#{lastname}

#{email_label}:
#{email}

#{birthdate_label}:
#{birthdate}


#{mainphone_label}:
#{mainphone}

#{mobilephone_label}:
#{mobilephone}

#{hometown_label}:
#{hometown}

#{firstlanguage_label}:
#{firstlanguage}

#{languages_label}:
1. #{language1}  - #{read1} - #{write1} - #{speak1}
2. #{language2}  - #{read2} - #{write2} - #{speak2}
3. #{language3}  - #{read3} - #{write3} - #{speak3}

#{profession_label}:
#{profession}
 
#{time_label}:
#{time}
 
#{whelp_label}:
#{whelp}



EOF
    msg # end of rawtext 
    Net::SMTP.start("smtp.kabbalah.info", 25,
                      'helodomain.com','yaakov','einodmilvado', :plain ) { |smtp|
      smtp.sendmail msg, 'manpowerform@kab.co.il', [adress_to]
    }
    
    
   response_text = params[:response_text]
   
   respond_to do |format|
      format.html {
       render :text => response_text
       return
        
      }
      format.json {
        render :text => response_text 
        return
      }
    end 
    
  end
  
end
