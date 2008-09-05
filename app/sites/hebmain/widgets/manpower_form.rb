class Hebmain::Widgets::ManpowerForm < WidgetManager::Base
    
  def render_full
    w_class('cms_actions').new(:tree_node => tree_node, :options => {:buttons => %W{ delete_button  edit_button }, :position => 'bottom'}).render_to(doc)
    title = get_name
    email = get_email
  
    
    
    action = 'mail/'+@tree_node.parent_id.to_s
    div(:class => 'manpower'){
      h3{text title}
      form(:action => action, :method => 'post', :id =>'manpower_form'){
        table{
          tr(:class => 'section' ){
            td(:colspan => '4'){text _('Personnal details')}
          }
          tr{
            td(:class => 'first, must'){
              text _('First Name')
              text ' *:'
            }
            td{
              input :type => 'text', :name => 'firstname'
            } 
            td(:class => 'second, must'){
              text _('Email')
              text ' *:'
            }
            td{
              input :type => 'text', :name => 'email'
            }
          }
          tr{  
            td(:class => 'first, must'){
              text _('Last Name')
              text ' *:'
            }
            td{
              input :type => 'text', :name => 'lastname'
            }
            td(:class => 'second'){
              text _('Mobile Phone')
              text ' :'
            }
            td{
              input :type => 'text', :name => 'mobilephone'
            }
          }
          tr{
            td(:class => 'first'){
              text _('Year of Birth')
              text ' :'
            }
            td{
              select(:name => 'birthdate'){
                #range
                ('1930'..'2002').each{|year|
                  option(:value => year){text year}
                }
              }
            }
            
            td(:class => 'second, must'){
              text _('Main phone')
              text ' *:'
            }
            td{
              input :type => 'text', :name => 'mainphone'
            }
          }
          tr{
            td(:class => 'first, must'){
              text _('Hometown')
              text ' *:'
            }
            td{
              input :type => 'text', :name => 'hometown'
            }
            
            td(:class => 'second, must'){
              text _('First Language')
              text ' *:'
            }
            td{
              input :type => 'text', :name => 'firstlanguage'
            }
          }


          tr{td{text ''}}
          tr(:class => 'section' ){
            td(:colspan => '4'){text _('Knowledge of languages')}
          }
          
          tr{
            td(:class => 'first'){
              text _('Language Name')
              text ' :'
            }
            td{
              select(:name => 'language1'){
               list_of_country
              }
            }
            td(:class => 'checkbox', :colspan => '2'){
              text _('Read')
              input :type => 'checkbox', :name => 'read1', :value => 'Read', :class => 'check'
              text _('Write')
              input :type => 'checkbox', :name => 'write1', :value => 'Write', :class => 'check'
              text _('Speak')
              input :type => 'checkbox', :name => 'speak1', :value => 'Speak', :class => 'check'
            }           
          }

          tr{
            td(:class => 'first'){
              text _('Language Name')
              text ' :'
            }
            td{
              select(:name => 'language2'){
                list_of_country
              }
            }
            td(:class => 'checkbox', :colspan => '2'){
              text _('Read')
              input :type => 'checkbox', :name => 'read2', :value => 'Read', :class => 'check'
              text _('Write')
              input :type => 'checkbox', :name => 'write2', :value => 'Write', :class => 'check'
              text _('Speak')
              input :type => 'checkbox', :name => 'speak2', :value => 'Speak', :class => 'check'
            }
          }

          tr{
            td(:class => 'first'){
              text _('Language Name')
              text ' :'
            }
            td{
              select(:name => 'language3'){
                list_of_country
              }
            }
            td(:class => 'checkbox', :colspan => '2'){
              text _('Read')
              input :type => 'checkbox', :name => 'read3', :value => 'Read', :class => 'check'
              text _('Write')
              input :type => 'checkbox', :name => 'write3', :value => 'Write', :class => 'check'
              text _('Speak')
              input :type => 'checkbox', :name => 'speak3', :value => 'Speak', :class => 'check'
            }
          }
          tr{td{text ''}}
          tr(:class => 'section' ){
            td(:colspan => '4'){text _('More details')}
          }

          tr{
            td(:class => 'first'){
              text _('Profession')
              text ' :'
            }
            td{
              input :type => 'text', :name => 'profession'
            }
          }

          tr{
            td(:class => 'first, must'){
              text _('Free Time')
              text ' *:'
            }
            td(:colspan => '2'){
              select(:name => 'time'){
                option(:value => "nil"){text '------'}
                option(:value => _('Less than 1h')){text _('Less than 1h')}
                option(:value => _('Between 2h up to 4h')){text _('Between 2h up to 4h')}
                option(:value => _('Between 4h to 6h')){text _('Between 4h to 6h')}
                option(:value =>  _('More than 6h')){text _('More than 6h')}
              }
            }
          }
          
          tr{
            td(:class => 'first, must'){
              text _('Where do you want to help?')
              text ' *:'
            }
            td(:colspan => '4'){
              textarea :rows => '6', :cols => '75', :name => 'whelp',  :class => 'msg'
            }
          }
          tr{
            td(:colspan => '3'){
              input :type => 'hidden', :name => 'sendmode', :value => 'manpower'
              input :type => 'hidden', :name => 'adresseto', :value => email
              input :type => 'submit', :value => _('submit'), :class => 'button'
              div(:id => "success"){
                text _('Everything went fine')
              }
            }
          }
        }
      }
    }
  end
  
  def list_of_country
    ["Hebrew","English", "Russian", "Spanish", "French", "German", "Arabic", "Greek", "Georgian", 
    "Danish",  "Ukranian", "Turkish", "Lithunian", "Latvian", "Macedonian", "Nederlands", "Polish", "Portugese", "Romanian",
    "Vietnamian", "Chinese", "Yiddish"].each{ |e|
      option(:value => e){text _(e)}
    }
  end
  
  
end