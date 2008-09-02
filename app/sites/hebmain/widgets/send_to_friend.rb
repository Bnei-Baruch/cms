class Hebmain::Widgets::SendToFriend < WidgetManager::Base
    
  def render_full
    div(:class => 'send_to_friend', :id => @tree_node.id, :lang => @presenter.website.prefix){
      form(:id => 'friend_form', :method => 'post', :action => '/'+@presenter.website.prefix+'/mail/'+@tree_node.id.to_s){
        table(:id => 'friend'){
          tr{
            td(:colspan => '2'){
              h1{text _('Send to friend')}
            }
          }
          tr{
            td{
              text _('Name of sender')
            }
            td{
              input :type => 'text', :size => '20', :name => 'sender_name'
            }
          }
          tr{
            td{
              text _('Name of receiver')
            }
            td{
              input :type => 'text', :size => '20', :name => 'receiver_name'
            }
          }
          tr{
            td{
              text _('Send to email address')
            }
            td{
              input :type => 'text', :size => '20', :name => 'adresseto'
            }
          }
          tr{
            td{
              input :type => 'submit', :class => 'button', :name => 'submit', :value => _('Send')
            }
          }
        }
      }
      span(:id => 'closed_friend'){
        img(:src => "/images/mail.jpg")
        span(:class => 'link_to_friend'){
          text 'שלח לחבר'
        }
      }
    }
  end

  
end
