class Mainsites::Widgets::SendToFriend < WidgetManager::Base
    
  def render_full
    div(:class => 'send_to_friend'){
      form(:id => 'friend_form', :method => 'post', :action => '/'+@presenter.website.prefix+'/mail/'+@tree_node.id.to_s){
        table(:id => 'friend'){
          tr{
            td(:colspan => '2'){
              h1{text _(:send_to_friend)}
            }
          }
          tr{
            td{
              text _(:name_of_sender)
            }
            td{
              input :type => 'text', :size => '20', :name => 'sender_name'
            }
          }
          tr{
            td{
              text _(:address_of_sender)
            }
            td{
              input :type => 'text', :size => '20', :name => 'adressefrom', :dir => 'ltr'
            }
          }
          tr{
            td{
              text _(:name_of_receiver)
            }
            td{
              input :type => 'text', :size => '20', :name => 'receiver_name'
            }
          }
          tr{
            td{
              text _(:send_to_email_address)
            }
            td{
              input :type => 'text', :size => '20', :name => 'adresseto', :dir => 'ltr'
            }
          }
          tr{
            td{
              input :type => 'submit', :class => 'button', :name => 'submit', :value => _(:send)
              input :type => 'reset', :class => 'button', :name => 'cancel', :id => 'stf_cancel', :value => _(:cancel)
              input :type => 'hidden', :name => 'subject', :value => _(:stf_subject)
            }
          }
        }
      }
      span(:id => 'closed_friend'){
        img(:src => "/images/mail.jpg", :alt => 'close')
        span(:class => 'link_to_friend'){
          text _(:send_to_friend)
        }
      }
    }
  end

  
end
