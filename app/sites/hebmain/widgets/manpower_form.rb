class Hebmain::Widgets::ManpowerForm < WidgetManager::Base
    
  def render_full
    w_class('cms_actions').new(:tree_node => tree_node, :options => {:buttons => %W{ delete_button  edit_button }, :position => 'bottom'}).render_to(self)
    title = get_name
    email = get_email
  
    
    
    action = 'mail/'+@tree_node.parent_id.to_s
    div(:class => 'manpower'){
      h3{text title}
      form(:action => action, :method => 'post', :id =>'manpower_form'){
        table{
          tr(:class => 'section' ){
            td(:colspan => '4'){text _(:'personnal_details')}
          }
          tr{
            td(:class => 'first, must'){
              text _(:'first_name')
              text ' *:'
            }
            td{
              input :type => 'text', :name => 'firstname'
            } 
            td(:class => 'second, must'){
              text _(:'email')
              text ' *:'
            }
            td{
              input :type => 'text', :name => 'email'
            }
          }
          tr{  
            td(:class => 'first, must'){
              text _(:'last_name')
              text ' *:'
            }
            td{
              input :type => 'text', :name => 'lastname'
            }
            td(:class => 'second'){
              text _(:'mobile_phone')
              text ' :'
            }
            td{
              input :type => 'text', :name => 'mobilephone'
            }
          }
          tr{
            td(:class => 'first'){
              text _(:'year_of_birth')
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
              text _(:'main_phone')
              text ' *:'
            }
            td{
              input :type => 'text', :name => 'mainphone'
            }
          }
          tr{
            td(:class => 'first, must'){
              text _(:'hometown')
              text ' *:'
            }
            td{
              input :type => 'text', :name => 'hometown'
            }
            
            td(:class => 'second, must'){
              text _(:'first_language')
              text ' *:'
            }
            td{
              input :type => 'text', :name => 'firstlanguage'
            }
          }


          tr{td{text ''}}
          tr(:class => 'section' ){
            td(:colspan => '4'){text _(:'knowledge_of_languages')}
          }
          
          tr{
            td(:class => 'first'){
              text _(:'language_name')
              text ' :'
            }
            td{
              select(:name => 'language1'){
               list_of_country
              }
            }
            td(:class => 'checkbox', :colspan => '2'){
              text _(:'read')
              input :type => 'checkbox', :name => 'read1', :value => 'Read', :class => 'check'
              text _(:'write')
              input :type => 'checkbox', :name => 'write1', :value => 'Write', :class => 'check'
              text _(:'speak')
              input :type => 'checkbox', :name => 'speak1', :value => 'Speak', :class => 'check'
            }           
          }

          tr{
            td(:class => 'first'){
              text _(:'language_name')
              text ' :'
            }
            td{
              select(:name => 'language2'){
                list_of_country
              }
            }
            td(:class => 'checkbox', :colspan => '2'){
              text _(:'read')
              input :type => 'checkbox', :name => 'read2', :value => 'Read', :class => 'check'
              text _(:'write')
              input :type => 'checkbox', :name => 'write2', :value => 'Write', :class => 'check'
              text _(:'speak')
              input :type => 'checkbox', :name => 'speak2', :value => 'Speak', :class => 'check'
            }
          }

          tr{
            td(:class => 'first'){
              text _(:'language_name')
              text ' :'
            }
            td{
              select(:name => 'language3'){
                list_of_country
              }
            }
            td(:class => 'checkbox', :colspan => '2'){
              text _(:'read')
              input :type => 'checkbox', :name => 'read3', :value => 'Read', :class => 'check'
              text _(:'write')
              input :type => 'checkbox', :name => 'write3', :value => 'Write', :class => 'check'
              text _(:'speak')
              input :type => 'checkbox', :name => 'speak3', :value => 'Speak', :class => 'check'
            }
          }
          tr{td{text ''}}
          tr(:class => 'section' ){
            td(:colspan => '4'){text _(:'more_details')}
          }

          tr{
            td(:class => 'first'){
              text _(:'profession')
              text ' :'
            }
            td{
              input :type => 'text', :name => 'profession'
            }
          }

          tr{
            td(:class => 'first, must'){
              text _(:'free_time')
              text ' *:'
            }
            td(:colspan => '2'){
              select(:name => 'time'){
                option(:value => "nil"){text '------'}
                option(:value => _(:'less_than_1h')){text _(:'less_than_1h')}
                option(:value => _(:'between_2h_up_to_4h')){text _(:'between_2h_up_to_4h')}
                option(:value => _(:'between_4h_to_6h')){text _(:'between_4h_to_6h')}
                option(:value =>  _(:'more_than_6h')){text _(:'more_than_6h')}
              }
            }
          }
          
          tr{
            td(:class => 'first, must'){
              text _(:'where_do_you_want_to_help')
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
              input :type => 'submit', :value => _(:'submit'), :class => 'button'
              div(:id => "success"){
                text _(:'everything_went_fine')
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
      option(:value => e){text _(('manpower_form.'+e.downcase).to_sym)}
    }
  end
  
  
end