class Mainsites::Widgets::ManpowerForm < WidgetManager::Base

  def render_email
    address_to = get_email
    email = get_gemail
    password = get_gpassword
    key = get_gkey

    firstname = @options[:firstname]
    lastname = @options[:lastname]
    email = @options[:email]
    mobilephone = @options[:mobilephone]
    birthdate = @options[:birthdate]
    mainphone = @options[:mainphone]
    hometown = @options[:hometown]
    firstlanguage = @options[:firstlanguage]
    language1 = @options[:language1]
    read1 = @options[:read1]
    write1 = @options[:write1]
    speak1 = @options[:speak1]
    language2 = @options[:language2]
    read2 = @options[:read2]
    write2 = @options[:write2]
    speak2 = @options[:speak2]
    language3 = @options[:language3]
    read3 = @options[:read3]
    write3 = @options[:write3]
    speak3 = @options[:speak3]
    profession = @options[:profession]
    time = @options[:time]
    whelp = @options[:whelp]

    firstname_label = _(:first_name)
    lastname_label = _(:last_name)
    email_label = _(:email)
    birthdate_label = _(:year_of_birth)
    mainphone_label = _(:main_phone)
    mobilephone_label = _(:mobile_phone)
    hometown_label = _(:hometown)
    firstlanguage_label = _(:first_language)
    languages_label = _(:knowledge_of_languages)
    profession_label = _(:profession)
    time_label = _(:free_time)
    whelp_label = _(:where_do_you_want_to_help)

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
      # Net::SMTP.start("smtp.kabbalah.info", 25, 'helodomain.com','user','pass', :plain ) { |smtp|
    begin
      Net::SMTP.start("localhost", 25) { |smtp|
        smtp.sendmail msg, 'manpowerform@kab.co.il', [address_to]
      }
    rescue
    end

    submit_to_google email, password, key, @options

    response_text = @options[:response_text]

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

  def submit_to_google(email, password, key, options)
    require 'google_spreadsheet'
    session = GoogleSpreadsheet.login(email, password)
    spreadsheet = session.spreadsheet_by_key(key)
    ws = spreadsheet.worksheets[0]
    ws.set_header_columns(@options.first)
    ws.populate(@options)
    ws.save

    a = 1
  end

  def render_full
    w_class('cms_actions').new(:tree_node => tree_node, :options => {:buttons => %W{ delete_button  edit_button }, :position => 'bottom'}).render_to(self)

    div(:class => 'manpower') {
      h3 { text get_name }

      form(:action => get_page_url(@presenter.node), :method => 'post', :id =>'manpower_form') {
        table {
          tr(:class => 'section') {
            td(:colspan => '4') { text _(:'personnal_details') }
          }
          tr {
            td(:class => 'first must') {
              text _(:'first_name')
              text ' *:'
            }
            td {
              input :type => 'text', :name => 'options[firstname]'
            }
            td(:class => 'second must') {
              text _(:'email')
              text ' *:'
            }
            td {
              input :type => 'text', :name => 'options[email]'
            }
          }
          tr {
            td(:class => 'first must') {
              text _(:'last_name')
              text ' *:'
            }
            td {
              input :type => 'text', :name => 'options[lastname]'
            }
            td(:class => 'second') {
              text _(:'mobile_phone')
              text ' :'
            }
            td {
              input :type => 'text', :name => 'options[mobilephone]'
            }
          }
          tr {
            td(:class => 'first') {
              text _(:'year_of_birth')
              text ' :'
            }
            td {
              select(:name => 'options[birthdate]') {
                #range
                ('1930'..'2002').each { |year|
                  option(:value => year) { text year }
                }
              }
            }

            td(:class => 'second must') {
              text _(:'main_phone')
              text ' *:'
            }
            td {
              input :type => 'text', :name => 'options[mainphone]'
            }
          }
          tr {
            td(:class => 'first must') {
              text _(:'hometown')
              text ' *:'
            }
            td {
              input :type => 'text', :name => 'options[hometown]'
            }

            td(:class => 'second must') {
              text _(:'first_language')
              text ' *:'
            }
            td {
              input :type => 'text', :name => 'options[firstlanguage]'
            }
          }


          tr { td { text '' } }
          tr(:class => 'section') {
            td(:colspan => '4') { text _(:'knowledge_of_languages') }
          }

          tr {
            td(:class => 'first') {
              text _(:'language_name')
              text ' :'
            }
            td {
              select(:name => 'options[language1]') {
                list_of_country
              }
            }
            td(:class => 'checkbox', :colspan => '2') {
              text _(:'read')
              input :type => 'checkbox', :name => 'options[read1]', :value => 'Read', :class => 'check'
              text _(:'write')
              input :type => 'checkbox', :name => 'options[write1]', :value => 'Write', :class => 'check'
              text _(:'speak')
              input :type => 'checkbox', :name => 'options[speak1]', :value => 'Speak', :class => 'check'
            }
          }

          tr {
            td(:class => 'first') {
              text _(:'language_name')
              text ' :'
            }
            td {
              select(:name => 'options[language2]') {
                list_of_country
              }
            }
            td(:class => 'checkbox', :colspan => '2') {
              text _(:'read')
              input :type => 'checkbox', :name => 'options[read2]', :value => 'Read', :class => 'check'
              text _(:'write')
              input :type => 'checkbox', :name => 'options[write2]', :value => 'Write', :class => 'check'
              text _(:'speak')
              input :type => 'checkbox', :name => 'options[speak2]', :value => 'Speak', :class => 'check'
            }
          }

          tr {
            td(:class => 'first') {
              text _(:'language_name')
              text ' :'
            }
            td {
              select(:name => 'options[language3]') {
                list_of_country
              }
            }
            td(:class => 'checkbox', :colspan => '2') {
              text _(:'read')
              input :type => 'checkbox', :name => 'options[read3]', :value => 'Read', :class => 'check'
              text _(:'write')
              input :type => 'checkbox', :name => 'options[write3]', :value => 'Write', :class => 'check'
              text _(:'speak')
              input :type => 'checkbox', :name => 'options[speak3]', :value => 'Speak', :class => 'check'
            }
          }
          tr { td { text '' } }
          tr(:class => 'section') {
            td(:colspan => '4') { text _(:'more_details') }
          }

          tr {
            td(:class => 'first') {
              text _(:'profession')
              text ' *:'
            }
            td(:colspan => '4') {
              textarea :rows => '7', :cols => '75', :name => 'options[profession]', :class => 'msg'
            }
          }

          tr {
            td(:class => 'first must') {
              text _(:'free_time')
              text ' *:'
            }
            td(:colspan => '2') {
              select(:name => 'options[time]') {
                option(:value => "nil") { text '------' }
                option(:value => _(:'less_than_1h')) { text _(:'less_than_1h') }
                option(:value => _(:'between_2h_up_to_4h')) { text _(:'between_2h_up_to_4h') }
                option(:value => _(:'between_4h_to_6h')) { text _(:'between_4h_to_6h') }
                option(:value => _(:'more_than_6h')) { text _(:'more_than_6h') }
              }
            }
          }

          tr {
            td(:class => 'first must') {
              text _(:'where_do_you_want_to_help')
              text ' *:'
            }
            td(:colspan => '4') {
              textarea :rows => '7', :cols => '75', :name => 'options[whelp]', :class => 'msg'
            }
          }
          tr {
            td(:colspan => '3') {
              input :type => 'hidden', :name => 'options[sendmode]', :value => 'manpower'
              input :type => 'submit', :value => _(:'submit'), :class => 'button'
              div(:id => "success") {
                text _(:'everything_went_fine')
              }
            }
          }
        }

        input :type => 'hidden', :name => 'options[widget_node_id]', :value => tree_node.id
        input :type => 'hidden', :name => 'options[widget]', :value => 'manpower_form'
        input :type => 'hidden', :name => 'view_mode', :value => 'email'
      }
    }
  end

  def list_of_country
    ["Hebrew", "English", "Russian", "Spanish", "French", "German", "Arabic", "Greek", "Georgian",
     "Danish", "Ukranian", "Turkish", "Lithunian", "Latvian", "Macedonian", "Nederlands", "Polish", "Portugese", "Romanian",
     "Vietnamian", "Chinese", "Yiddish"].each { |e|
      option(:value => e) { text _((e.downcase).to_sym) }
    }
  end


end
