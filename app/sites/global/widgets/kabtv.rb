require 'open-uri'

class Global::Widgets::Kabtv < WidgetManager::Base

  def initialize(*args, &block)
    super
    @language = get_language
    @web_node_url = get_page_url(@presenter.node)
  end

  def render_homepage
    div(:id => 'home-kabtv') {
      cms_action
      #      We don't want to use different backgrounds here
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
                    var firstclick = true;
                    if (typeof $.livequery == "function") {
                      $("#kabtv-news .newstitle").livequery('click',function () {
                      var $this = $(this);
                      $this.next().children().toggle();
                      $this.children().toggleClass('tvnewsiteminus').toggleClass('tvnewsiteplus');
                    });
                     $("#home-kabtv .box1_headersection_tv").livequery('click',function () {
                      if (firstclick) {
                          google_tracker('/homepage/widget/kabtv/open_schedule');
                          firstclick = false;
                      }
                      var $this = $(this);
                      $this.next().toggle();
                      $this.children().toggleClass('futurprogram-plus').toggleClass('futurprogram-minus');
                     });
                    }
          TV
        }
      }
      div(:id => 'kabtv-bot'){
        a(:href => get_target, :onclick => "google_tracker('/homepage/widget/kabtv/go_to_tv');") {span(:class => 'text-tv'){ text _(:tothetvchannel)} }
      }
      div(:class => "clear")
      if get_golive
        div(:id => 'kabtv-live'){
          div(:class => "live-event"){text get_golive_text}
          a(:href => get_golive_link) {span(:class => 'text-live'){ text _(:clicktogolive)} }
        }
      end
      div(:class => 'box1_headersection_tv'){span(:class => 'futurprogram-plus'){text _(:future_programs)}}
      div(:id => 'kabtv-mid'){
      }
      div(:class => "clear")
      # display_current_program
      javascript {
        rawtext "function currentProgram(){"
        rawtext "$('#kabtv-mid').load('#{@web_node_url}',{view_mode:'current_program','options[widget]':'kabtv','options[widget_node_id]':#{tree_node.id}})"
        rawtext "}"
        rawtext "$(function() {"
        rawtext "  currentProgram();"
        rawtext "  setInterval(currentProgram, 300000);"
        rawtext "})"
      }
      cms_action_for_site_updates
      div(:id => 'kabtv-news'){
        # display
        w_class('cms_actions').new(:tree_node => tree_node,
          :options => {:buttons => %W{ new_button },
            :resource_types => %W{ site_updates },
            :new_text => 'new news',
            :has_url => false,
            :placeholder => 'left'}).render_to(self)
        if show_content_resources(:resources => news_resources, :force_mode => 'kabtv', :sortable => true).empty?
          javascript{
            rawtext <<-SCHED
                $(window).load(function () {
                  // run code
                    $("#home-kabtv .box1_headersection_tv").next().toggle().prev().children().addClass('futurprogram-minus').removeClass('futurprogram-plus');
                });
            SCHED
          }
        end
      }
    }
  end
  
  def render_full
    url = Language.get_url(@language)
    javascript <<-KABTV
//***************************************
// KAB.TV Player
//***************************************

var sketchTimer;
function startSketches(){
    sketchTimer = setInterval(reloadSketches, 30000)
}
function stopSketches(){
    clearTimeout(sketchTimer)
}
var questionsTimer;
function startQuestions(){
    questionsTimer = setInterval(reloadQuestions, 60000)
}
function stopQuestions(){
    clearTimeout(questionsTimer)
}
function stopPlayer(){
    var player = document.getElementById("player");
    if (player && player.controls && player.controls.isAvailable('Stop'))
        player.controls.stop();
}
function detach(){
    var player = document.getElementById("player");
    if (player && player.URL){
        stopPlayer();
        player.openPlayer(player.URL);
    }
}
function gofs(){
    var player = document.getElementById("player");
    if (player && player.playState == 3) {
        alert(fs_str);
        player.fullScreen = 'true';
    } else {
        alert(nofs_str);
    }
}
$(function() {
    if (typeof $("#tabs").tabs == "function") {
      $("#tabs").tabs({
        show:
        // On switch between tabs...
        function(event, ui){
            stopSketches();
            stopQuestions();
            if (ui.tab.hash == "#sketch"){
                reloadSketches();
                startSketches();
            } else if (ui.tab.hash == "#questions"){
                reloadQuestions();
                startQuestions();
            }
        }
      });
    }
    if (typeof reloadSchedule == "function") {
        reloadSchedule();
    }
    if (typeof $.livequery == "function") {
        $("a.schedule_menu_item").livequery('click',function () {
            $("div.schedule_day").hide();
            $("#schedule_list div#D_" + this.id).show();
            $("a.schedule_menu_item").removeClass('schedule_selected');
            $(this).toggleClass('schedule_selected');
            return false;
        });
        $("#kabtv  #schedule_list .title").livequery('click',function () {
            var $this = $(this);
            $this.next().toggle();
            $(this).toggleClass('icon-plus');
            $(this).toggleClass('icon-minus');
        });
       $("#kabtv-news .newstitle").livequery('click',function () {
            var $this = $(this);
            $this.next().toggle();
        });
    }
    if (typeof hs != "undefined") {
        hs.graphicsDir = '../highslide/graphics/';
        hs.wrapperClassName = 'highslide-white';
        hs.outlineType = 'rounded-white';
        hs.showCredits = 0;
        hs.useControls = true;
        hs.fixedControls = true;
        hs.fadeInOut = true;
        hs.transitions = ['expand', 'crossfade'];
        hs.targetX = 'kabtv';
        hs.targetY = 'kabtv';
        hs.lang = {
            loadingText : 'טוען...',
            loadingTitle : 'לחץ לביטול',
            focusTitle : 'Click to bring to front',
            fullExpandText : 'גודל מקסימלי',
            fullExpandTitle : 'הגדל לגודל המקסימלי (f)',
            creditsText : 'Powered by <i>Highslide JS</i>',
            creditsTitle : 'Go to the Highslide JS homepage',
            previousText : 'תמונה קודמת',
            previousTitle : 'תמונה הקודמת (חץ שמאלה)',
            nextText : 'תמונה הבאה',
            nextTitle : 'תמונה הבאה (חץ ימינה)',
            moveText : 'הזז',
            moveTitle : 'לחץ ומשוך להזזה',
            closeText : 'סגור',
            closeTitle : 'סגור (esc)',
            resizeTitle : 'שנה גודל',
            playText : 'Play',
            playTitle : 'Play slideshow (spacebar)',
            pauseText : 'Pause',
            pauseTitle : 'Pause slideshow (spacebar)',
            number: 'תמונה %1 / %2',
            restoreTitle : 'לחץ לסגירה. לחץ ומשוך להזזה. תשתמש בחצים לתמונה הבאה/קודמת.'
        };
        if (hs.registerOverlay) {
            // The white controlbar overlay
            hs.registerOverlay({
                thumbnailId: null,
                overlayId: 'controlbar',
                position: 'top right',
                hideOnMouseOut: false,
                useControls: true
            });
        }
    }
    $("#kabtv #ask_btn").click(function() {
        $("#kabtv #q").hide();
        $("#kabtv #ask_btn").hide();
        $("#kabtv #ask_question").show();
    });
    $("#kabtv #ask_cancel").click(function() {
        $("#kabtv #ask_question").hide();
        $("#kabtv #q").show();
        $("#kabtv #ask_btn").show();
    });
    $("#kabtv #ask").submit(function() {
        var question = $.trim($("#kabtv #options_qquestion")[0].value);
        if (question == "") {
          alert('נא לכתוב שאלה');
          return false;
        }
        $("#kabtv #kabtv-loading").show();
        $(this).ajaxSubmit(function(responseText, statusCode){
            $("#kabtv #kabtv-loading").hide();
            alert(responseText);
            if (statusCode == "success") {
              $("#kabtv #ask_question").hide();
              $("#kabtv #q").show();
              $("#kabtv #ask_btn").show();
            }
        });
        // always return false to prevent standard browser submit and page navigation
        return false;
    });

});
    KABTV
    div(:id => 'kabtv', :style => "background-image:url(#{get_background});") {
      cms_action
      javascript {
        rawtext 'function reloadSketches(){'
        rawtext "$('#sketch').load('#{@web_node_url}',{view_mode:'sketches','options[widget]':'kabtv','options[widget_node_id]':#{tree_node.id}})"
        rawtext '}'
        rawtext 'function reloadQuestions(){'
        rawtext "$('#questions #q').load('#{@web_node_url}',{view_mode:'questions','options[widget]':'kabtv','options[widget_node_id]':#{tree_node.id}})"
        rawtext '}'
        rawtext 'function reloadSchedule(){'
        rawtext "$('#schedule').load('#{@web_node_url}',{view_mode:'schedule','options[widget]':'kabtv','options[widget_node_id]':#{tree_node.id}})"
        rawtext '}'
      }

      div(:id => 'tabs') {
        ul(:class => 'ui-tabs-nav'){
          li{a(:href => '#schedule'){span _(:schedule)}} unless @options[:no_schedule]
          li{a(:href => '#questions'){span _(:questions)}} unless @options[:no_questions]
          li{a(:href => '#sketch'){span _(:sketches)}} unless @options[:no_sketches]
        }
        div(:id => 'schedule'){
          img(:id => 'kabtv-loader', :src => "/images/ajax-loader.gif", :alt => "")
        } unless @options[:no_schedule]
        div(:id => 'questions'){
          h3 {rawtext _(:students_questions)}
          div(:id => 'q') {
            img(:id => 'kabtv-loader', :src => "/images/ajax-loader.gif", :alt => "")
          }
          ask_button_and_form
        } unless @options[:no_questions]
        div(:id => 'sketch'){
          img(:id => 'kabtv-loader', :src => "/images/ajax-loader.gif", :alt => "")
        } unless @options[:no_sketches]
      }
      height = @options[:height] || 336
      width = @options[:width] || 378
      div(:id => 'player-side') {
        javascript {
          #               This should be an Ajax
          rawtext <<-TV
                    if (jQuery.browser.ie) {
                        document.write('<object classid="clsid:6BF52A52-394A-11D3-B153-00C04F79FAA6" style="background-color:#000000" id="player" name="player" type="application/x-oleobject" width="#{width}" height="#{height}" standby="Loading Windows Media Player components..."><param name="URL" value="#{url}" /><param name="AutoStart" value="1" /><param name="AutoPlay" value="1" /><param name="volume" value="50" /><param name="uiMode" value="full" /><param name="animationAtStart" value="1" /><param name="showDisplay" value="1" /><param name="transparentAtStart" value="0" /><param name="ShowControls" value="1" /><param name="ShowStatusBar" value="1" /><param name="ClickToPlay" value="0" /><param name="bgcolor" value="#000000" /><param name="windowlessVideo" value="1" /><param name="balance" value="0" /></object>');
                    } else if (jQuery.browser.firefox) {
                        document.write('<embed id="player" name="player" src="#{url}" type="application/x-mplayer2" pluginspage="http://activex.microsoft.com/activex/controls/mplayer/en/nsmp2inf.cab#Version=6,4,7,1112" autostart="true" stretchToFit="false" autosize="false" uimode="full" width="#{width}" height="#{height}" />');
                    } else {
                        document.write('<object classid="clsid:6BF52A52-394A-11D3-B153-00C04F79FAA6" style="background-color:#000000" id="player" name="player" type="application/x-oleobject" width="#{width}" height="#{height}" standby="Loading Windows Media Player components..."><param name="URL" value="#{url}" /><param name="AutoStart" value="1" /><param name="AutoPlay" value="1" /><param name="volume" value="50" /><param name="uiMode" value="full" /><param name="animationAtStart" value="1" /><param name="showDisplay" value="1" /><param name="transparentAtStart" value="0" /><param name="ShowControls" value="1" /><param name="ShowStatusBar" value="1" /><param name="ClickToPlay" value="0" /><param name="bgcolor" value="#000000" /><param name="windowlessVideo" value="1" /><param name="balance" value="0" />');
                        document.write('<embed id="player" name="player" src="#{url}" type="application/x-mplayer2" pluginspage="http://activex.microsoft.com/activex/controls/mplayer/en/nsmp2inf.cab#Version=6,4,7,1112" autostart="true" stretchToFit="false" uimode="full" width="#{width}" height="#{height}" />');
                        document.write('</object>');
                    }
          TV
          rawtext <<-TV1
          fs_str='#{_(:to_exit_full_screen_mode_press_ESC)}';
          nofs_str='#{_(:to_watch_in_full_screen_mode_please_start_player_beforehand)}';
          TV1
        }
        div(:id => 'player_options'){
          div(:id => 'separate-msg'){
            rawtext _(:for_full_screen_mode_double_click_on_player)
          }
          a(:id => 'separate-win', :href => "", :title => "", :onclick => 'detach();return false') {
            rawtext _(:in_separate_player)
          }
          a(:id => 'full-win', :href => "", :title => "", :onclick => 'gofs();return false') {
            rawtext _(:full_screen)
          }

          url = get_troubleshooting_url
          if !url.empty?
            div(:id => 'troubleshooting_str'){
              rawtext _(:troubleshooting)
              a(:id => 'troubleshooting_url', :target => 'blank', :title => "", :href => url) {
                rawtext _(:click_here)
              }
            }
          end
        }
      }
      div(:class => 'clear')
    }
  end

  def render_questions
    question = Question.approved_questions
    if question.blank?
      div(:class => 'question0') {
        div(:class => 'who') {
          rawtext _(:no_new_questions)
        }
      }
      div(:class => 'question2') { rawtext '&nbsp;' }
      return
    end
    question.each_with_index { |q, index|
      div(:class => "question#{index % 2}") {
        div(:class => 'who') {
          if !q.qname.blank? && !q.qfrom.blank?
            rawtext q.qname
            rawtext " #{_(:from)} "
            rawtext q.qfrom
            rawtext ':'
          elsif q.qname.blank? && q.qfrom.blank?
            rawtext _(:guest)
            rawtext ':'
          elsif q.qname.blank?
            rawtext _(:guest)
            rawtext " #{_(:from)} "
            rawtext q.qfrom
            rawtext ':'
          else
            rawtext q.qname
            rawtext ":"
          end

        }
        div(:class => 'what') {rawtext h(q.qquestion)}
      }
      div(:class => 'question2') { rawtext '&nbsp;' }
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
    h3{rawtext _(:current_sketch)}
    if content['last-sketch'].blank?
      h3{rawtext _(:no_sketches_yet)}
      return
    end
    a(:id => 'last-sketch', :href => "#{sketches_url}/#{content['last-sketch']}", :title => "",
      :class => 'highslide', :onclick => 'return hs.expand(this)') {
      img(:id => 'last-sketch-img', :src => "#{sketches_url}/#{content['last-sketch']}", :alt => "")
    }
    div(:id=>"controlbar", :class=>'highslide-overlay controlbar') {
      a(:href=>'#', :class=>'previous', :onclick=>'return hs.previous(this)', :title=>_(:prev_picture))
      a(:href=>'#', :class=>'next', :onclick=>'return hs.next(this)', :title=>_(:next_picture))
      a(:href=>'#', :class=>'highslide-move', :onclick=>'return false', :title=>_(:click_and_drag))
      a(:href=>'#', :class=>'close', :onclick=>'return hs.close(this)', :title=>_(:close))
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
      rawtext :temporarily_impossible_to_ask_questions
      return
    end
    if options['qquestion'].empty?
      rawtext _(:you_must_fill_field_question)
      return
    end

    begin
      Question.create :qname => options['qname'],
        :qfrom => options['qfrom'],
        :qquestion => options['qquestion'],
        :isquestion => 1,
        :lang => @language.humanize,
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

  def render_schedule
    day_names = [_(:sun), _(:mon), _(:tue), _(:wed), _(:thu), _(:fri), _(:sat)]

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

  def render_news
    w_class('cms_actions').new(:tree_node => tree_node,
      :options => {:buttons => %W{ new_button },
        :resource_types => %W{ site_updates },
        :new_text => 'new news',
        :has_url => false,
        :placeholder => 'left'}).render_to(self)
    show_content_resources(:resources => news_resources, :force_mode => 'kabtv', :sortable => true)
  end
  
  private
  
  def site_update_entries
    TreeNode.get_subtree(
      :parent => tree_node.id,
      :resource_type_hrids => ['video'],
      :depth => 1,
      :status => ['PUBLISHED', 'DRAFT']
    )
  end

  def news_resources
    @news ||= TreeNode.get_subtree(
      :parent => tree_node.id,
      :resource_type_hrids => ['site_updates'],
      :depth => 1,
      :status => ['PUBLISHED', 'DRAFT']
    )
  end

  def ask_button_and_form
    div :class => 'prebutton'
    input(:id => 'ask_btn', :type => "button", :value => _(:ask_question), :title => _(:ask_question),
      :name => "subscribe", :class => "button", :alt => _(:ask_question))
    div :class => 'postbutton'
    div :class => 'clear'
    div(:id => 'ask_question', :style => 'display:none') {
      div(:id => 'ask_question-ie') {
        img(:id => 'kabtv-loading', :src => "/images/ajax-loader.gif", :alt => "", :style => 'display:none')
        h3 {rawtext _(:ask_question)}
        form(:id => 'ask', :action => "#{@web_node_url}", :method => 'post'){
          div{
            div(:class => 'q') {
              label(:for => 'options_qname') {rawtext _(:your_name)}
              input :type => 'text', :id => 'options_qname', :name => 'options[qname]', :value => '', :size => '31', :class => 'text'
            }
            div(:class => 'q') {
              label(:for => 'options_qfrom') {rawtext _(:your_location)}
              input :id => 'options_qfrom', :type => 'text', :name => 'options[qfrom]', :value => '', :size => '31', :class => 'text'
            }
            div(:class => 'q') {
              label(:class => 'ta-label', :for => 'options_qquestion') {rawtext _(:question)}
              textarea :id => 'options_qquestion', :name => 'options[qquestion]', :class => 'textarea', :cols => 30, :rows => 10
            }
            div :class => 'prebutton'
            input(:id => 'ask_submit', :type => "submit", :value => _(:send), :title => _(:send),
              :name => "ask", :class => "button", :alt => _(:send))
            div :class => 'postbutton'
            div :class => 'prebutton'
            input(:id => 'ask_cancel', :type => "button", :value => _(:cancel), :title => _(:cancel),
              :name => "cancel", :class => "button", :alt => _(:cancel))
            div :class => 'postbutton'
            div :class => 'clear'
            input :type => 'hidden', :name => 'options[widget_node_id]', :value => tree_node.id
            input :type => 'hidden', :name => 'options[widget]', :value => 'kabtv'
            input :type => 'hidden', :name => 'view_mode', :value => 'new_question'
          }
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
        div(:class => 'hdr'){ rawtext _(:broadcasting_now)}
        format_item(item)
        div(:class => 'hdr'){ rawtext _(:future_programs)}
        found = true
      end
    }
  end

  def format_item(item)
    time = sprintf("%02d:%02d",
      item.start_time / 100,
      item.start_time % 100)
    title = item.title.gsub '[\r\n]', ''
    title.gsub!(/href=([^"])(\S+)/, 'href="\1\2" ')
    title.gsub!('target=_blank', 'class="target_blank"')
    title.gsub!('target="_blank"', 'class="target_blank"')
    title.gsub!('&main', '&amp;main')
    title.gsub!('<br>', '<br/>')
    title.gsub!(/<font\s+color\s*=\s*["\'](\w+)["\']>/, '')
    title.gsub!('</font>', '')
    title.gsub!(/\s+/, '&nbsp;')
    div(:class => 'item'){
      div(:class => 'time'){ rawtext time }
      div(:class => 'title'){ rawtext title }
      div(:class => 'clear')
    }
  end

  # For 'today' select 'hour'
  def get_list_for(day, hour, dayname, today)
    months = [_(:january), _(:february), _(:march), _(:april), _(:may), _(:june),
      _(:july), _(:august), _(:september), _(:october), _(:november), _(:december)]
    nobroad = " #{_(:no_broadcast_on)}"
    broad = "#{_(:broadcast_on)}"
    
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
    return "<h3>#{nobroad} #{dayname}, #{dm}</h3>" if alist.blank?
    list = "<h3>#{broad} #{dayname}, #{dm}</h3>"
    alist.each_with_index { |item, index|
      time = sprintf("<div class='time'>%02d:%02d - %s</div>",
        item.start_time / 100,
        item.start_time % 100,
        calc_end_time(item.start_time, item.duration))
      title = item.title.gsub '[\r\n]', ''
      title.gsub! '<div>', ''
      title.gsub! '</div>', ''
      descr = item.descr.gsub '[\r\n]', ''
      descr.gsub!(/href=([^"])(\S+)/, 'href="\1\2" ')
      descr.gsub!('target=_blank', 'class="target_blank"')
      descr.gsub!('target="_blank"', 'class="target_blank"')
      descr.gsub!('&main', '&amp;main')
      descr.gsub!('<br>', '<br/>')
      descr.gsub!(/<font\s+color\s*=\s*["\'](\w+)["\']>/, '<span style="color:\1">')
      descr.gsub!(/<font\s+color\s*=\s*["\'](#[0-9A-Fa-f]+)["\']>/, '<span style="color:\1">')
      descr.gsub!('</font>', '</span>')
      list += "<div class='item#{index % 2}'>#{time}<div class='title icon-plus'>#{title}</div><div style='display:none;' class='descr'>#{descr}</div></div>"
    }
    
    list + '<div class="item2">&nbsp;</div>'
  end

  def calc_end_time(start, dur)
    eh = dur / 60
    em = dur - eh * 60
    eh = start / 100 + eh
    em = (start % 100) + em
    if em >= 60
      eh += em / 60
      em %= 60
    end
    sprintf("%02d:%02d", eh, em)
  end

  def cms_action
    w_class('cms_actions').new(
      :tree_node => tree_node,
      :options => {
        :button_text => _(:edit_kabtv_widget),
        :buttons => %W{ delete_button  edit_button }
      }).render_to(self)
  end

  def cms_action_for_site_updates
    w_class('cms_actions').new(:tree_node => tree_node,
      :options => {:buttons => %W{ new_button },
        :resource_types => %W{ site_updates },
        :button_text => _(:news_for_tv),
        :new_text => _(:add_newsbox_for_tv),
        :has_url => false,
        :placeholder => 'home_kabtv'}).render_to(self)
  end
end
