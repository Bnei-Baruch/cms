class Notifier < ActionMailer::Base
  

  
  def contact(recipient, mail_from, subject, message, sent_at = Time.now)
      @subject = subject
      @recipients = recipient
      @from = mail_from
      @sent_on = sent_at
   	  @body["message"] = message
  end

end
