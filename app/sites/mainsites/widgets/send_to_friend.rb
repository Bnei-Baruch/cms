class Mainsites::Widgets::SendToFriend < WidgetManager::Base

  def render_full
    div(:id => 'closed_friend',
      :style => "background-image:url(/images/#{@presenter.site_settings[:site_name]}/services.gif)"){
      span(:class => 'link_friend'){
        text _(:send_to_friend)
      }
    }
    div(:id => 'send_to_friend'){
      form(:id => 'friend_form', :method => 'post', :action => '/'+@presenter.website.prefix+'/mail/'+@tree_node.id.to_s){
        table(:id => 'friend'){
          tr{
            td(:colspan => '2'){div(:class => 'h-h1'){text _(:send_to_friend)}}
          }
          tr{
            td(:class => 'text'){span _(:name_of_sender)}
            td(:class => 'input'){input :type => 'text', :size => '20', :name => 'sender_name'}
          }
          tr{
            td(:class => 'text'){span _(:address_of_sender)}
            td(:class => 'input'){input :type => 'text', :size => '20', :name => 'adressefrom', :dir => 'ltr'}
          }
          tr{
            td(:class => 'text'){span _(:name_of_receiver)}
            td(:class => 'input'){input :type => 'text', :size => '20', :name => 'receiver_name'}
          }
          tr{
            td(:class => 'text'){span _(:send_to_email_address)}
            td(:class => 'input'){input :type => 'text', :size => '20', :name => 'adresseto', :dir => 'ltr'}
          }
          tr{
            td{}
            td{
              a(:onclick => '$("#friend_form").submit();return false;',
                :class => 'button',
                :style => "background-image:url(/images/#{@presenter.site_settings[:site_name]}/button.gif)") {
                rawtext _(:send)
              }
              a(:id => 'stf_cancel',
                :class => 'button',
                :style => "background-image:url(/images/#{@presenter.site_settings[:site_name]}/button.gif)") {
                rawtext _(:cancel)
              }
            }
            input :type => 'hidden', :name => 'subject', :value => _(:stf_subject)
          }
        }
      }
    }
  end

end
