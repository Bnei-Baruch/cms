class Notifier < ActionMailer::Base
  
  def encode(value)
    value.scan(/.{1,45}/).map{|c| [c].pack('m').sub(/\n/, '')}.map{|e| "=?UTF-8?B?#{e}?=" }.join("\n\s")
  end


  def contact(recipient, mail_from, subject, message, sent_at = Time.now)
      @subject = encode(subject)
      @recipients = recipient
      @from = mail_from
      @sent_on = sent_at
   	  @body["message"] = message
  end

  def student(recipient, mail_from, subject, message, sent_at = Time.now)
    recipients [recipient]
    from mail_from
    subject encode(subject)
    sent_on sent_at
    charset 'utf-8'

    content_type 'multipart/alternative'
    part :content_type => 'text/html' do |p|
      p.body = message
      p.transfer_encoding = 'quoted-printable'
    end
  end
end
