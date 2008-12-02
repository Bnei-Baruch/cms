require 'open-uri'

class Hebmain::Widgets::Kabtv < WidgetManager::Base

    def initialize(*args, &block)
        super
        @language = get_language
        @web_node_url = get_page_url(@presenter.node)
        @presenter.disable_cache
    end

                        
    #  div(:class => 'tv') {
    #    div(:class => 'play play-in')
    #    div(:class => 'stop stop-out')
    #    a(:class => 'right', :id => 'full_screen', :href => '') {rawtext _('למסך מלא')}
    #    div(:class => 'clear'){rawtext '&nbsp;'}
    #  }
    def render_homepage
        div(:id => 'home-kabtv') {
            cms_action
            div(:id => 'kabtv-top'){
                height = 214
                width = 199
                url = Language.get_url(@language)
                javascript {
                    rawtext <<-TV
                    if (jQuery.browser.ie) {
                        document.write('<object classid="clsid:6BF52A52-394A-11D3-B153-00C04F79FAA6" style="background-color:#000000" id="player" name="player" type="application/x-oleobject" width="#{width}" height="#{height}" standby="Loading Windows Media Player components..."><param name="URL" value="#{url}" /><param name="AutoStart" value="1" /><param name="AutoPlay" value="1" /><param name="mute" value="1" /><param name="volume" value="50" /><param name="uiMode" value="mini" /><param name="animationAtStart" value="1" /><param name="showDisplay" value="1" /><param name="transparentAtStart" value="0" /><param name="ShowControls" value="1" /><param name="ShowStatusBar" value="0" /><param name="ClickToPlay" value="0" /><param name="bgcolor" value="#000000" /><param name="windowlessVideo" value="1" /><param name="balance" value="0" /></object>');
                    } else if (jQuery.browser.firefox) {
                        document.write('<embed id="player" name="player" src="#{url}" type="application/x-mplayer2" pluginspage="http://activex.microsoft.com/activex/controls/mplayer/en/nsmp2inf.cab#Version=6,4,7,1112" autostart="true" stretchToFit="false" autosize="false" uimode="full" width="#{width}" height="#{height}"/>');
                    } else {
                        document.write('<object classid="clsid:6BF52A52-394A-11D3-B153-00C04F79FAA6" style="background-color:#000000" id="player" name="player" type="application/x-oleobject" width="#{width}" height="#{height}" standby="Loading Windows Media Player components..."><param name="URL" value="#{url}" /><param name="AutoStart" value="1" /><param name="AutoPlay" value="1" /><param name="mute" value="1" /><param name="volume" value="50" /><param name="uiMode" value="mini" /><param name="animationAtStart" value="1" /><param name="showDisplay" value="1" /><param name="transparentAtStart" value="0" /><param name="ShowControls" value="1" /><param name="ShowStatusBar" value="0" /><param name="ClickToPlay" value="0" /><param name="bgcolor" value="#000000" /><param name="windowlessVideo" value="1" /><param name="balance" value="0" />');
                        document.write('<embed id="player" name="player" src="#{url}" type="application/x-mplayer2" pluginspage="http://activex.microsoft.com/activex/controls/mplayer/en/nsmp2inf.cab#Version=6,4,7,1112" autostart="true" stretchToFit="false" uimode="full" width="#{width}" height="#{height}" mute="1" />');
                        document.write('</object>');
                    }
                    TV
                }
            }
            div(:id => 'kabtv-mid'){
            }
            # display_current_program
            javascript {
                rawtext "function reloadSchedule(){"
                rawtext "$('#kabtv-mid').load('#{@web_node_url}',{view_mode:'current_program','options[widget]':'kabtv','options[widget_node_id]':#{tree_node.id}})"
                rawtext "}; reloadSchedule();setInterval(reloadSchedule, 300000)"
            }
            div(:id => 'kabtv-bot'){
                a(:href => get_target) {
                    img(:id => 'yellow-button', :src => "/images/hebmain/kabtv/home-button.gif", :alt => "לכל תוכניות הטלוויזיה")
                }
            }
        }
    end
  
    def render_full
        @url = Language.get_url(@language)
        #        text Question.approved_questions.inspect
        #        br
        #        text @presenter.controller.request
        div(:id => 'kabtv') {
            cms_action
            javascript() {
                rawtext 'function reloadSketches(){'
                rawtext "$('#sketch').load('#{@web_node_url}',{view_mode:'sketches','options[widget]':'kabtv','options[widget_node_id]':#{tree_node.id}})"
                rawtext '}'
                rawtext 'function reloadQuestions(){'
                rawtext "$('#questions #q').load('#{@web_node_url}',{view_mode:'questions','options[widget]':'kabtv','options[widget_node_id]':#{tree_node.id}})"
                rawtext '}'
            }

            div(:id => 'tabs') {
                ul(:class => 'ui-tabs-nav'){
                    li{a(:href => '#schedule'){span 'לוח שידורים'}}
                    li{a(:href => '#questions'){span 'שאלות'}}
                    li{a(:href => '#sketch'){span 'שרטוטים'}}
                }
                div(:id => 'schedule', :style => 'float:left'){
                    display_schedule
                }
                div(:id => 'questions', :style => 'float:left'){
                    h3 {rawtext 'שאלות התלמידים'}
                    div(:id => 'q') { render_questions }
                    ask_button_and_form
                }
                div(:id => 'sketch', :style => 'float:left'){
                }
            }
            height = 336
            width = 378
            div(:id => 'player-side') {
                javascript {
                    #               This should be an Ajax
                    rawtext <<-TV
                    if (jQuery.browser.ie) {
                        document.write('<object classid="clsid:6BF52A52-394A-11D3-B153-00C04F79FAA6" style="background-color:#000000" id="player" name="player" type="application/x-oleobject" width="#{width}" height="#{height}" standby="Loading Windows Media Player components..."><param name="URL" value="#{@url}" /><param name="AutoStart" value="1" /><param name="AutoPlay" value="1" /><param name="volume" value="50" /><param name="uiMode" value="full" /><param name="animationAtStart" value="1" /><param name="showDisplay" value="1" /><param name="transparentAtStart" value="0" /><param name="ShowControls" value="1" /><param name="ShowStatusBar" value="1" /><param name="ClickToPlay" value="0" /><param name="bgcolor" value="#000000" /><param name="windowlessVideo" value="1" /><param name="balance" value="0" /></object>');
                    } else if (jQuery.browser.firefox) {
                        document.write('<embed id="player" name="player" src="#{@url}" type="application/x-mplayer2" pluginspage="http://activex.microsoft.com/activex/controls/mplayer/en/nsmp2inf.cab#Version=6,4,7,1112" autostart="true" stretchToFit="false" autosize="false" uimode="full" width="#{width}" height="#{height}" />');
                    } else {
                        document.write('<object classid="clsid:6BF52A52-394A-11D3-B153-00C04F79FAA6" style="background-color:#000000" id="player" name="player" type="application/x-oleobject" width="#{width}" height="#{height}" standby="Loading Windows Media Player components..."><param name="URL" value="#{@url}" /><param name="AutoStart" value="1" /><param name="AutoPlay" value="1" /><param name="volume" value="50" /><param name="uiMode" value="full" /><param name="animationAtStart" value="1" /><param name="showDisplay" value="1" /><param name="transparentAtStart" value="0" /><param name="ShowControls" value="1" /><param name="ShowStatusBar" value="1" /><param name="ClickToPlay" value="0" /><param name="bgcolor" value="#000000" /><param name="windowlessVideo" value="1" /><param name="balance" value="0" />');
                        document.write('<embed id="player" name="player" src="#{@url}" type="application/x-mplayer2" pluginspage="http://activex.microsoft.com/activex/controls/mplayer/en/nsmp2inf.cab#Version=6,4,7,1112" autostart="true" stretchToFit="false" uimode="full" width="#{width}" height="#{height}" />');
                        document.write('</object>');
                    }
                    TV
                    rawtext <<-TV1
                    fs_str='ESC ליציאה ממצב "מסך מלא" לחץ על';
                    nofs_str='נא להפעיל נגנ ע"מ לצפותו במסך מלא';
                    TV1
                }
                #                text 'jQuery.browser.ie'
                div(:id => 'player_options'){
                    div(:id => 'separate-msg'){
                        rawtext 'למסך מלא יש ללחוץ לחיצה כפולה על הנגן'
                    }
                    a(:id => 'separate-win', :href => "", :title => "", :onclick => 'detach();return false') {
                        rawtext 'לצפייה בנגן מדיה'
                    }
                    a(:id => 'full-win', :href => "", :title => "", :onclick => 'gofs();return false') {
                        rawtext 'למסך מלא'
                    }
                }
            }
            div(:class => 'clear')
        }
    end

    def render_questions
        question = Question.approved_questions
        if question.blank?
            div(:class => 'question0') {rawtext 'אין שאלות חדשות.'}
            return
        end
        question.each_with_index { |q, index|
            div(:class => "question#{index % 2}") {
                div(:class => 'who') {
                    if !q.qname.blank? && !q.qfrom.blank?
                        rawtext q.qname
                        rawtext '  מ- '
                        rawtext q.qfrom
                        rawtext ':'
                    elsif q.qname.blank? && q.qfrom.blank?
                        rawtext 'אורח'
                        rawtext ':'
                    elsif q.qname.blank?
                        rawtext 'אורח'
                        rawtext '  מ- '
                        rawtext q.qfrom
                        rawtext ':'
                    else
                        rawtext q.qname
                        rawtext ":"
                    end

                }
                div(:class => 'what') {rawtext q.qquestion}
            }
        }
    end

    def render_sketches
        content =
          begin
            Timeout::timeout(25){
                open('http://www.kab.tv/classboard/classboard-yml.php') { |f|
                    YAML::load(f)
                }
            }
        rescue Timeout::Error
            ''
        end
        thumbnails_url = content['urls'][0]['thumbnails']
        sketches_url = content['urls'][1]['sketches']
        h3{rawtext 'השרטוט הנוכחי '}
        if content['last-sketch'].blank?
            h3{rawtext 'איו עוד שרטוטים'}
            return
        end
        a(:id => 'last-sketch', :href => "#{sketches_url}/#{content['last-sketch']}", :title => "",
            :class => 'highslide', :onclick => 'return hs.expand(this)') {
            img(:id => 'last-sketch-img', :src => "#{sketches_url}/#{content['last-sketch']}", :alt => "")
        }
        div(:id=>"controlbar", :class=>'highslide-overlay controlbar') {
            a(:href=>'#', :class=>'previous', :onclick=>'return hs.previous(this)', :title=>'תמונה הקודמת (חץ שמאלה)')
            a(:href=>'#', :class=>'next', :onclick=>'return hs.next(this)', :title=>'תמונה הבאה (חץ ימינה)')
            a(:href=>'#', :class=>'highslide-move', :onclick=>'return false', :title=>'לחץ ומשוך להזזה')
            a(:href=>'#', :class=>'close', :onclick=>'return hs.close(this)', :title=>'סגור (esc)')
        }

        div(:id => 'thumbnails'){
            content['thumbnails'].each{ |thumbnail|
                a(:href => "#{sketches_url}/#{thumbnail}", :title => "",
                    :class => 'highslide', :onclick => 'return hs.expand(this)') {
                    img(:src => "#{thumbnails_url}/#{thumbnail}", :alt => "")
                }
            }
        } unless content['thumbnails'].blank?
    end

    def render_new_question
        unless BaseParam.enabled('kab.tv')
            rawtext 'לא ניתן כרגע לשאול שאלות'
            return
        end
        if options['qquestion'].empty?
            rawtext 'שדה "שאלה" הינו שדה חובה'
            return
        end

        begin
            Question.create :qname => options['qname'],
              :qfrom => options['qfrom'],
              :qquestion => options['qquestion'],
              :isquestion => 1,
              :lang => 'Hebrew',
              :is_hidden => 0,
              :ip => '',
              :country_name => '',
              :country_code => '',
              :region => '',
              :city => '',
              :timestamp => Time.now.to_s(:db)

        rescue Exception => ex
            rawtext "Exception: " + ex
            return
        end

        rawtext 'Thank you for your question'
    end
  
    def render_current_program
        d = Date.today
        today = d.strftime('%A') # day number 0..6
        d = DateTime.now
        hour  = d.hour
        min   = d.min
        get_list_for_time(today, hour, min, 2)
        div(:class => 'clear')
    end

    private

    def ask_button_and_form
        input(:id => 'ask_btn', :type => "button", :value => "שאל שאלה", :title => "שאל שאלה",
            :name => "subscribe", :class => "button", :alt => "שאל שאלה")
        div(:id => 'ask_question', :style => 'display:none') {
            div(:id => 'ask_question-ie') {
                img(:id => 'kabtv-loading', :src => "/images/ajax-loader.gif", :alt => "", :style => 'display:none')
                h3 {rawtext 'שאל שאלה'}
                form(:id => 'ask', :action => "#{@web_node_url}", :method => 'post'){
                    p{
                        div(:class => 'q') {
                            label(:for => 'options_qname') {rawtext 'שמך'}
                            input :type => 'text', :id => 'options_qname', :name => 'options[qname]', :value => '', :size => '31', :class => 'text'
                        }
                        div(:class => 'q') {
                            label(:for => 'options_qfrom') {rawtext 'מקומך'}
                            input :type => 'text', :name => 'options[qfrom]', :value => '', :size => '31', :class => 'text'
                        }
                        div(:class => 'q') {
                            label(:class => 'ta-label', :for => 'options_qquestion') {rawtext 'שאלה'}
                            textarea :name => 'options[qquestion]', :class => 'textarea', :cols => 30, :rows => 10
                        }
                        input(:id => 'ask_submit', :type => "submit", :value => "שלח", :title => "שלח",
                            :name => "ask", :class => "button", :alt => "שלח")
                        input(:id => 'ask_cancel', :type => "button", :value => "בטל", :title => "בטל",
                            :name => "cancel", :class => "button", :alt => "בטל")
                        input :type => 'hidden', :name => 'options[widget_node_id]', :value => tree_node.id
                        input :type => 'hidden', :name => 'options[widget]', :value => 'kabtv'
                        input :type => 'hidden', :name => 'view_mode', :value => 'new_question'
                    }
                }
            }
        }
    end

    def display_schedule
        day_names = ["ראשון", "שני", "שלישי", "רביעי", "חמישי", "שישי", "שבת"]

        d = Date.today
        today = d.strftime('%A') # day number 0..6
        hour  = d.strftime("%H") # hour in 24-hour format

        div(:id => 'schedule_menu'){
            %w( Sunday Monday Tuesday Wednesday Thursday Friday Saturday ).each_with_index { |day, index|
                selected = (day == today) ? 'schedule_selected' : ''
                a day_names[index], :id => "#{day}_#{index}", :href => '#', :class => 'schedule_menu_item ' + selected
            }
        }
        div(:id => 'schedule_list') {
            %w( Sunday Monday Tuesday Wednesday Thursday Friday Saturday ).each_with_index { |day, index|
                display = (day == today) ? '' : 'display:none'
                div(:id => "D_#{day}_#{index}", :class => 'schedule_day', :style => display){
                    rawtext get_list_for(day, hour, day_names[index], day == today)
                }
            }
        }
    end

    def get_list_for_time(day, hour, min, amount)
        alist = Listing.get_day(@language, day)
        looking_for_time = hour * 60 + min
        found = false
        alist.each { |item|
            start_program = item.start_time / 100 * 60 + item.start_time % 100
            end_program = start_program + item.duration
            if found && (amount > 0)
                format_item(item)
                amount -= 1
            elsif (start_program <= looking_for_time) && (looking_for_time < end_program)
                div(:class => 'hdr'){ rawtext 'עכשיו בשידור'}
                format_item(item)
                div(:class => 'hdr'){ rawtext 'התוכניות הבאות'}
                found = true
            end
        }
    end

    def format_item(item)
        time = sprintf("%02d:%02d",
            item.start_time / 100,
            item.start_time % 100)
        title = item.title.gsub '[\r\n]', ''
        title.gsub!(/href=[^"](\S+)/, 'href="\1" ')
        title.gsub!('target=_blank', 'class="target_blank"')
        title.gsub!('target="_blank"', 'class="target_blank"')
        title.gsub!('&main', '&amp;main')
        title.gsub!('<br>', '<br/>')
        title.gsub!(/<font\s+color\s*=\s*["\'](\w+)["\']>/, '')
        title.gsub!('</font>', '')
        div(:class => 'item'){
            div(:class => 'time'){
                rawtext time
            }
            div(:class => 'title'){
                rawtext title
            }
            div(:class => 'clear')
        }
    end

    # For 'today' select 'hour'
    def get_list_for(day, hour, dayname, today)
        months = ["לינואר", "לפברואר", "למרץ", "לאפריל", "למאי", "ליוני", "ליולי", "לאוגוסט", "לספטמבר", "לאוקטובר", "לנובמבר", "לדצמבר"]
        nobroad = "אין שידורים ביום "
        broad = "שידור ביום "
    
        aday = DatesSchedule.get_day(@language, day)
        if aday.kind_of?(Array) and !aday.blank?
            d = aday[0].d
            m = aday[0].m - 1
        else
            d = 1
            m = 0
        end
        dm = "#{d} #{months[m]}"

        alist = Listing.get_day(@language, day)
        return "<h3>#{nobroad}#{dayname}, #{dm}</h3>" if alist.blank?
        list = "<h3>#{broad}#{dayname}, #{dm}</h3>"
        alist.each_with_index { |item, index|
            time = sprintf("<div class='time'>%02d:%02d - %s</div>",
                item.start_time / 100,
                item.start_time % 100,
                calc_end_time(item.start_time, item.duration))
            title = item.title.gsub '[\r\n]', ''
            descr = item.descr.gsub '[\r\n]', ''
            list += "<div class='item#{index % 2}'>#{time}<b>#{title}</b><br/>#{descr}</div>"
            list.gsub!(/href=[^"](\S+)/, 'href="\1" ')
            list.gsub!('target=_blank', 'class="target_blank"')
            list.gsub!('target="_blank"', 'class="target_blank"')
            list.gsub!('&main', '&amp;main')
            list.gsub!('<br>', '<br/>')
            list.gsub!(/<font\s+color\s*=\s*["\'](\w+)["\']>/, '<span style="color:\1">')
            list.gsub!('</font>', '</span>')
        }
    
        list
    end

    def calc_end_time(start, dur)
        eh = dur / 60
        em = dur - eh * 60
        eh = start / 100 + eh
        em = (start % 100) + em
        while em >= 60
            em -= 60
            eh += 1
        end
        sprintf("%02d:%02d", eh, em)
    end

    def cms_action
        w_class('cms_actions').new(
            :tree_node => tree_node,
            :options => {
                :button_text => 'עריכת יחידת טלוויזיה',
                :buttons => %W{ delete_button  edit_button }
            }).render_to(doc)
    end
end
