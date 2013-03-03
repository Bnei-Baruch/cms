class EmailController < ApplicationController
  require 'net/smtp'
  require 'base64'
  require 'rest_client'

  def send_node
    adresse_to = params[:adresseto]
    node_id = params[:id]
    adresse_from = params[:adressefrom]
    sender_name = params[:sender_name]
    receiver_name = params[:receiver_name]
    sendmode = params[:sendmode]
    sendsubject = params[:subject]

    sendsubject = sendsubject.gsub('sender_name', sender_name)
    sendsubject = sendsubject.gsub('receiver_name', receiver_name)

    my_array = sendsubject.split()
    puts my_array
    enc_test =''
    my_array.each { |i|
      str = i + ' '
      enc_test = enc_test + ' =?UTF-8?B?' + Base64.b64encode(str).chop + '?='
    }

    host = 'http://' + request.host
    prefix = params[:prefix]

    my_port = request.server_port.to_s
    portinurl = my_port == '80' ? '' : ':' + my_port

    url = host + portinurl + '/' + prefix + '/short/' + node_id

    send_mail(url, adresse_to, adresse_from, sender_name, receiver_name, enc_test)
    render :nothing => true, :status => 200 and return
    #redirect_to url


  end

  #def send_mail(email_dest = '', add_from = '', url = '')
  #def send_mail(url = '')
  def send_mail(url = '', adresse_to ='', adresse_from ='', sender_name = '', receiver_name = '', sendsubject = '')
    msg = <<EOF
From: #{adresse_from}
Content-Type: text/plain; charset=utf-8
Subject: #{sendsubject}

שלום #{receiver_name} חברך #{sender_name} ממליץ לך על הלינק הזה
#{url}

EOF
    msg # end of rawtext 
        #Net::SMTP.start("smtp.kabbalah.info", 25, 'helodomain.com','user','pass', :plain ) { |smtp|
    Net::SMTP.start("localhost", 25) { |smtp|
      smtp.sendmail msg, adresse_from, [adresse_to]
    }

  end

  def new_home_mail
    name = params[:YMP0]
    email = params[:YMP2]
    adresse_from = "#{name} <#{email}>"
    adresse_to = 'Bait Hadash <bait2bb@gmail.com>'
    free_text = params[:free_text]

    agree = params[:agree]
    ymlp = "http://ymlp.com/subscribe.php?YMLPID=#{params[:ymlp]}"

    # 1. Subscribe to YMLP
    if agree == 'subscribe'
      response = RestClient.post ymlp, :YMP0 => name, :YMP2 => email, :action => 'subscribe'
    else
      response = 'OK'
    end

    ymlp_result = response.to_s =~ /ERROR/ ? 'ERROR' : 'OK'

    msg = <<-MSG
From: #{adresse_to}
To: #{adresse_to}
Content-Type: text/plain; charset=utf-8
Subject: From kab.co.il to new building manpower

My email: #{adresse_from}
I know to do:
#{free_text}

Technical info:
#{agree ? 'AGREE ' : 'DON\'T AGREE'} to subscribe
#{agree ? "YMLP returned #{ymlp_result}" : 'YMPL was not connected'}
    MSG

    # 2. Sent email
    if Rails.env.production?
      Net::SMTP.start("smtp.kabbalah.info", 25, 'helodomain.com', 'user', 'pass', :plain) { |smtp|
        smtp.sendmail msg, adresse_to, [adresse_to]
      }
    else
      Net::SMTP.start("localhost", 25) { |smtp|
        smtp.sendmail msg, adresse_to, [adresse_to, 'gshilin@gmail.com']
      }
    end

    # 3. Redirect back
    flash[:notice] = response.to_s =~ /ERROR/ ? 'אירעה שגיעה. אנא נסה שוב מיוחר יותר' : 'בקשתך נשלחה בהצלחה'
    redirect_to request.env['HTTP_REFERER'], :notice => ymlp_result
  end

end
