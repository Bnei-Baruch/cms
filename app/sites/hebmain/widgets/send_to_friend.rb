class Hebmain::Widgets::SendToFriend < WidgetManager::Base
    
  def render_full
    div(:class => 'send_to_friend'){
      form(:id => 'friend_form', :method => 'post', :action => '/'+@presenter.website.prefix+'/mail/'+@tree_node.id.to_s){
        table(:id => 'friend'){
          tr{
            td(:colspan => '2'){
              h1{text I18n.t(:send_to_friend)}
            }
          }
          tr{
            td{
              text I18n.t(:name_of_sender)
            }
            td{
              input :type => 'text', :size => '20', :name => 'sender_name'
            }
          }
          tr{
            td{
              text I18n.t(:address_of_sender)
            }
            td{
              input :type => 'text', :size => '20', :name => 'adressefrom', :dir => 'ltr'
            }
          }
          tr{
            td{
              text I18n.t(:name_of_receiver)
            }
            td{
              input :type => 'text', :size => '20', :name => 'receiver_name'
            }
          }
          tr{
            td{
              text I18n.t(:send_to_email_address)
            }
            td{
              input :type => 'text', :size => '20', :name => 'adresseto', :dir => 'ltr'
            }
          }
          tr{
            td{
              input :type => 'submit', :class => 'button', :name => 'submit', :value => I18n.t(:send)
              input :type => 'reset', :class => 'button', :name => 'cancel', :id => 'stf_cancel', :value => I18n.t(:cancel)
              input :type => 'hidden', :name => 'subject', :value => I18n.t(:stf_subject)
            }
          }
        }
      }
      span(:id => 'closed_friend'){
        img(:src => "/images/mail.jpg", :alt => 'close')
        span(:class => 'link_to_friend'){
          text 'שלח לחבר'
        }
      }
    }
  end

  
end
