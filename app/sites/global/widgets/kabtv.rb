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
        if get_prefer_bbplayer == true
          rawtext get_bbplayer
        elsif get_prefer_flash == true
          render_homepage_flash
        else
          render_homepage_wmv
				end
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
# ZZZ HEB-422 - To add Facebook's Like button and Like Box
#
#        w_class('cms_actions').new(:tree_node => tree_node,
#          :options => {:buttons => %W{ new_button },
#            :resource_types => %W{ site_updates },
#            :new_text => 'new news',
#            :has_url => false,
#            :placeholder => 'left'}).render_to(self)
#
#          if show_content_resources(:resources => news_resources, :force_mode => 'kabtv', :sortable => true).empty?
#          javascript{
#            rawtext <<-SCHED
#                $(window).load(function () {
#                  // run code
#                    $("#home-kabtv .box1_headersection_tv").next().toggle().prev().children().addClass('futurprogram-minus').removeClass('futurprogram-plus');
#                });
#            SCHED
#          }
#        end
      }
    }
  end
  
  def render_full
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
    $("a.schedule_menu_item").live('click',function () {
        $("div.schedule_day").hide();
        $("#schedule_list div#D_" + this.id).show();
        $("a.schedule_menu_item").removeClass('schedule_selected');
        $(this).toggleClass('schedule_selected');
        return false;
    });
    $("#kabtv  #schedule_list .title").live('click',function () {
        var $this = $(this);
        $this.next().toggle();
        $(this).toggleClass('icon-plus');
        $(this).toggleClass('icon-minus');
    });
   $("#kabtv-news .newstitle").live('click',function () {
        var $this = $(this);
        $this.next().toggle();
    });
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
    $("#kabtv #ask_btn1, #kabtv #ask_btn2").click(function() {
        $("#kabtv #q").hide();
        $("#kabtv #ask_btn1").hide();
        $("#kabtv #ask_btn2").hide();
        $("#kabtv #ask_question").show();
    });
    $("#kabtv #ask_cancel").click(function() {
        $("#kabtv #ask_question").hide();
        $("#kabtv #q").show();
        $("#kabtv #ask_btn1").show();
        $("#kabtv #ask_btn2").show();
    });
    $("#kabtv #ask").submit(function() {
        var question = $.trim($("#kabtv #options_qquestion")[0].value);
        if (question == "") {
          alert('נא למלא את השדות הריקים');
          return false;
        }
        alert("תודה על שאלתך/תגובתך!");
        $("#kabtv #q").show();
        $("#kabtv #ask_question").hide();
        $("#kabtv #ask_btn2").show();
        $("#kabtv #ask_btn1").show();
        $(this).ajaxSubmit(function(responseText, statusCode){
        });
        // always return false to prevent standard browser submit and page navigation
        return false;
    });

});
    KABTV
    force_wmv = @presenter.controller.params['force_wmv'].to_i
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
          img(:class => 'kabtv-loader', :src => "/images/ajax-loader.gif", :alt => "")
        } unless @options[:no_schedule]
        div(:id => 'questions'){
          #h3 {rawtext _(:students_questions)}
          ask_button_and_form
          div(:id => 'q') {
            img(:class => 'kabtv-loader', :src => "/images/ajax-loader.gif", :alt => "")
          }
					ask_button_only
        } unless @options[:no_questions]
        div(:id => 'sketch'){
          img(:class => 'kabtv-loader', :src => "/images/ajax-loader.gif", :alt => "")
        } unless @options[:no_sketches]
      }
      if get_prefer_bbplayer == true
      elsif get_prefer_flash == true && force_wmv != 1
        div(:id => 'cdn_logo_3dcdn'){
          a(:href => 'http://3dcdn.com/', :alt => '', :target => '_blank', :rel => 'nofollow')
        }
        div(:id => 'link_to_wmv') {
					a(:href => '?force_wmv=1', :alt => '', :onclick => "google_tracker('/homepage/widget/kabtv/force_wmv');") { rawtext 'לצפייה בנגן מדיה במקרה של הפרעות בשידור' }
				}
      else
        div(:id => 'cdn_logo_castup')
			end
      div(:id => 'player-side') {
				height = @options[:height] || 336
				width = @options[:width] || 378
				url, high_url, med_url, low_url, idx = Language.get_url(@language, @presenter.get_cookies)
        return if url.empty?

        if get_prefer_bbplayer == true
          rawtext get_bbplayer
        elsif get_prefer_flash == true && force_wmv != 1
          render_full_flash
        else
          render_full_wmv(url, width, height)
				end
				div(:id => 'player_options'){
          url = get_troubleshooting_url
          if !url.empty?
            div(:id => 'troubleshooting_str'){
              a(:id => 'troubleshooting_url', :target => 'blank', :title => "", :href => url) {
                rawtext _(:click_here)
              }
            }
          end

					if (get_prefer_bbplayer == false && get_prefer_flash != true || force_wmv == 1) && !get_hide_bitrates
						div(:id => 'bitrates'){
							#            rawtext 'איכות שידור: גבוהה | בינונית | נמוכה'
							rawtext _(:broadcast_quality) + ': '
							title = _(:high)
							klass = idx == 0 ? 'selected' : ''
							label(:for => 'name0') {
								input(:id => 'name0', :type => 'radio', :checked => idx == 0, :name => 'quality', :class => klass, :title => title, :onclick => "switchChannel('#{high_url}')")
								rawtext title
							} if high_url
							title = _(:medium)
							klass = idx == 1 ? 'selected' : ''
							label(:for => 'name1') {
								input(:id => 'name1', :type => 'radio', :checked => idx == 1, :name => 'quality', :class => klass, :title => title, :onclick => "switchChannel('#{med_url}')")
								rawtext title
							} if med_url
							title = _(:low)
							klass = idx == 2 ? 'selected' : ''
							label(:for => 'name2') {
								input(:id => 'name2', :type => 'radio', :checked => idx == 2, :name => 'quality', :class => klass, :title => title, :onclick => "switchChannel('#{low_url}')")
								rawtext title
							} if low_url
						} if high_url || med_url || low_url
					end

          div(:id => 'separate-msg'){
            rawtext _(:for_full_screen_mode_double_click_on_player)
          }
          a(:id => 'separate-win', :href => "", :title => "", :onclick => 'detach();return false') {
            rawtext _(:in_separate_player)
          }
          a(:id => 'full-win', :href => "", :title => "", :onclick => 'gofs();return false') {
            rawtext _(:full_screen)
          }
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
        open('http://www.kab.tv/classboard/thumbnails.yml') { |f|
          YAML::load(f)
        }
      }
    rescue Timeout::Error
      ''
    end
    thumbnails_url = content[:urls][:thumbnails]
    sketches_url = content[:urls][:sketches]
    sketches = content[:thumbnails]
    last_sketch = sketches.pop
    
    if last_sketch.nil?
      h3{rawtext _(:no_sketches_yet)}
      return
    end
    
    h3{rawtext _(:current_sketch)}
    a(:id => 'last-sketch', :href => "#{sketches_url}/#{last_sketch}", :title => "",
      :class => 'highslide', :onclick => 'return hs.expand(this)') {
      img(:id => 'last-sketch-img', :src => "#{sketches_url}/#{last_sketch}", :alt => "")
    }
    div(:id=>"controlbar", :class=>'highslide-overlay controlbar') {
      a(:href=>'#', :class=>'previous', :onclick=>'return hs.previous(this)', :title=>_(:prev_picture))
      a(:href=>'#', :class=>'next', :onclick=>'return hs.next(this)', :title=>_(:next_picture))
      a(:href=>'#', :class=>'highslide-move', :onclick=>'return false', :title=>_(:click_and_drag))
      a(:href=>'#', :class=>'close', :onclick=>'return hs.close(this)', :title=>_(:close))
    }

    div(:id => 'thumbnails'){
      sketches.each{ |thumbnail|
        a(:href => "#{sketches_url}/#{thumbnail}", :title => "",
          :class => 'highslide', :onclick => 'return hs.expand(this)') {
          img(:src => "#{thumbnails_url}/#{thumbnail}", :alt => "")
        }
      }
    } unless sketches.nil?
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
        :ip => "",
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
    javascript {
      rawtext "$(function() {"
      rawtext " $('a.target_blank').attr('target', '_blank');"
      rawtext "});"
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
  
	def render_full_wmv(url, width, height)
		rawtext <<-TV
			<div id="tvobj">
			<!--[If IE]>
			<object 
				classid="clsid:6BF52A52-394A-11D3-B153-00C04F79FAA6" 
				type="application/x-oleobject"
				id="player" 
				name="player" 
				data="#{url}" 
				width="#{width}" 
				height="#{height}">
				<param name="url" value="#{url}" />
				<param name="autostart" value="true" />
				<param name="controller" value="true" />
				<param name="volume" value="50" />
				<param name="uiMode" value="mini" />
				<param name="animationAtStart" value="true" />
				<param name="showDisplay" value="false" />   
				<param name="ShowAudioControls" value="true" />
				<param name="ShowPositionControls" value="false" />
				<param name="transparentAtStart" value="false" / >
				<param name="ShowControls" value="true" />
				<param name="ShowStatusBar" value="true" />
				<param name="ShowTracker" value="false" />
				<param name="ClickToPlay" value="false" />
				<param name="DisplayBackColor" value="#000000" />
				<param name="DisplayForeColor" value="#ffffff" />
				<param name="balance" value="false" />
			</object>
			<![endif]-->
			<!--[if !IE]>-->
			<object 
				type="application/x-oleobject"
				classid="CLSID:22D6F312-B0F6-11D0-94AB-0080C74C7E95"
				id="player" 
				name="player" 
				data="#{url}" 
				width="#{width}" 
				height="#{height}">
				<param name="src" value="#{url}" />
				<param name="autostart" value="true" />
				<param name="controller" value="true" />
				<param name="volume" value="50" />
				<param name="uiMode" value="mini" />
				<param name="animationAtStart" value="true" />
				<param name="showDisplay" value="false" />   
				<param name="ShowAudioControls" value="true" />
				<param name="ShowPositionControls" value="false" />
				<param name="transparentAtStart" value="false" />
				<param name="ShowControls" value="true" />
				<param name="ShowStatusBar" value="true" />
				<param name="ShowTracker" value="false" />
				<param name="ClickToPlay" value="false" />
				<param name="DisplayBackColor" value="#000000" />
				<param name="DisplayForeColor" value="#ffffff" />
				<param name="balance" value="false" />
                                <embed type="application/x-mplayer2" pluginspage="http://www.microsoft.com/Windows/MediaPlayer/"
				  src="#{url}" 
				  width="#{width}" 
				  height="#{height}"
                                  showcontrols=1
				  showstatusbar=1>
                                </embed>
			</object>
			<!--<![endif]-->
			</div>
			
		TV
		javascript {
			rawtext <<-TV1
			fs_str='#{_(:to_exit_full_screen_mode_press_ESC)}';
			nofs_str='#{_(:to_watch_in_full_screen_mode_please_start_player_beforehand)}';
			function switchChannel(url) {
					var player = document.getElementById("tvobj");
					if (player){
							tv = "<!--[If IE]> <object classid='clsid:6BF52A52-394A-11D3-B153-00C04F79FAA6' type='application/x-oleobject' id='player' name='player' data='"+url+"' width='#{width}' height='#{height}'> <param name='url' value='"+url+"' /> <param name='autostart' value='true' /> <param name='controller' value='true' /> <param name='volume' value='50' /> <param name='uiMode' value='mini' /> <param name='animationAtStart' value='true' /> <param name='showDisplay' value='false' />   <param name='ShowAudioControls' value='true' /> <param name='ShowPositionControls' value='false' /> <param name='transparentAtStart' value='false' / > <param name='ShowControls' value='true' /> <param name='ShowStatusBar' value='true' /> <param name='ShowTracker' value='false' /> <param name='ClickToPlay' value='false' /> <param name='DisplayBackColor' value='#000000' /> <param name='DisplayForeColor' value='#ffffff' /> <param name='balance' value='false' /> </object> <![endif]--> <!--[if !IE]>--> <object type='application/x-oleobject' classid='CLSID:22D6F312-B0F6-11D0-94AB-0080C74C7E95' id='player' name='player' data='"+url+"' width='#{width}' height='#{height}'> <param name='src' value='"+url+"' /> <param name='autostart' value='true' /> <param name='controller' value='true' /> <param name='volume' value='50' /> <param name='uiMode' value='mini' /> <param name='animationAtStart' value='true' /> <param name='showDisplay' value='false' />   <param name='ShowAudioControls' value='true' /> <param name='ShowPositionControls' value='false' /> <param name='transparentAtStart' value='false' /> <param name='ShowControls' value='true' /> <param name='ShowStatusBar' value='true' /> <param name='ShowTracker' value='false' /> <param name='ClickToPlay' value='false' /> <param name='DisplayBackColor' value='#000000' /> <param name='DisplayForeColor' value='#ffffff' /> <param name='balance' value='false' /> <embed type='application/x-mplayer2' pluginspage='http://www.microsoft.com/Windows/MediaPlayer/' src='#{url}' width='#{width}' height='#{height}' showcontrols=1 showstatusbar=1> </embed> </object> <!--<![endif]-->";
						player.innerHTML = tv;
						}
					}
			TV1
		}
	end

	def render_full_flash
		height = 304
		width = 378
		div(:id => "flashplayer-#{object_id}", :style => "height:#{height}px;width:#{width}px;position:relative;top:15px;"){}
		rawtext <<-cdn
<!-- load script for creating Flowplayer -->
<script type="text/javascript" src="/flowplayer/3dcdn/3dcdn.loader.js"></script>

<!-- load script for Analyzer -->
<script type="text/javascript" src="/flowplayer/3dcdn/3dcdn.analyzer.kabala.js"></script>
		cdn
		javascript {
			rawtext <<-Embedjs
				$(document).ready(function() {
						var varAnalyzerID = "#{get_analyzer_id}";
						var cdn_ClipURL =  "#{get_smil_url}";
						$('#home-kabtv #kabtv-top').height(270);
						 objPlayer = $f('flashplayer-#{object_id}',
                {src:'/flowplayer/3dcdn/3Dcdn.player.swf', version: [10, 0], cachebusting: $.browser.msie},
                {
								key:'#\@932a7f91ab5747d7f90',
								canvas: { 
									backgroundImage: 'url(/flowplayer/logo-10sec.swf)'
								},
								clip:{
									autoBuffering: 'true',
									autoPlay: 'true',
									provider: 'cdn',
									onStart: function() { 
											this.unmute(); 
									}
								},
								onBeforePause: function() { 
										return false; 
								},
								plugins: {
									controls: {
										all: false,
										volume: true,
										fullscreen: true,
										stop: true,
										mute: true
									},
									cdn: {
										host: varPostURL,
										playerId: varPlayerID,
										ownerId: varAnalyzerID,
										smilUrl: cdn_ClipURL,
										eventTarget: varIvivoPostURL,
                    bwDetect: true,
                    bwUseSO: false
									}
								}
						 });
			});
			addOnBeforeunloadEvent(sendLogoffEvent);
			Embedjs
		}
	end

	def render_homepage_wmv
		height = 214
		width = 199
		url = Language.get_url(@language, @presenter.get_cookies)[0]
		rawtext <<-TV1
			<div id="tvobj">
			<!--[If IE]>
			<object 
				classid="clsid:6BF52A52-394A-11D3-B153-00C04F79FAA6" 
				type="application/x-oleobject"
				id="player" 
				name="player" 
				data="#{url}" 
				width="#{width}" 
				height="#{height}">
				<param name="url" value="#{url}" />
				<param name="autostart" value="true" />
				<param name="controller" value="true" />
				<param name="volume" value="50" />
				<param name="uiMode" value="mini" />
				<param name="mute" value="true" />
				<param name="animationAtStart" value="true" />
				<param name="showDisplay" value="false" />   
				<param name="ShowAudioControls" value="true" />
				<param name="ShowPositionControls" value="false" />
				<param name="transparentAtStart" value="false" / >
				<param name="ShowControls" value="true" />
				<param name="ShowStatusBar" value="true" />
				<param name="ShowTracker" value="false" />
				<param name="ClickToPlay" value="false" />
				<param name="DisplayBackColor" value="#000000" />
				<param name="DisplayForeColor" value="#ffffff" />
				<param name="balance" value="false" />
			</object>
			<![endif]-->
			<!--[if !IE]>-->
			<object 
				type="application/x-oleobject"
				classid="CLSID:22D6F312-B0F6-11D0-94AB-0080C74C7E95"
				id="player" 
				name="player" 
				data="#{url}" 
				width="#{width}" 
				height="#{height}">
				<param name="src" value="#{url}" />
				<param name="autostart" value="true" />
				<param name="controller" value="true" />
				<param name="volume" value="50" />
				<param name="uiMode" value="mini" />
				<param name="mute" value="true" />
				<param name="animationAtStart" value="true" />
				<param name="showDisplay" value="false" />   
				<param name="ShowAudioControls" value="true" />
				<param name="ShowPositionControls" value="false" />
				<param name="transparentAtStart" value="false" />
				<param name="ShowControls" value="true" />
				<param name="ShowStatusBar" value="true" />
				<param name="ShowTracker" value="false" />
				<param name="ClickToPlay" value="false" />
				<param name="DisplayBackColor" value="#000000" />
				<param name="DisplayForeColor" value="#ffffff" />
				<param name="balance" value="false" />
                                <embed type="application/x-mplayer2" pluginspage="http://www.microsoft.com/Windows/MediaPlayer/"
				  src="#{url}" 
				  width="#{width}" 
				  height="#{height}"
                                  showcontrols=1 mute=1
				  showstatusbar=1>
                                </embed>

			</object>
			<!--<![endif]-->
			</div>
		TV1
		javascript {
			rawtext <<-TV
				var firstclick = true;
				$("#kabtv-news .newstitle").live('click',function () {
				  var $this = $(this);
				  $this.next().children().toggle();
				  $this.children().toggleClass('tvnewsiteminus').toggleClass('tvnewsiteplus');
			  });
			  $("#home-kabtv .box1_headersection_tv").live('click',function () {
				  if (firstclick) {
						google_tracker('/homepage/widget/kabtv/open_schedule');
						firstclick = false;
				  }
				  var $this = $(this);
				  $this.next().toggle();
				  $this.children().toggleClass('futurprogram-plus').toggleClass('futurprogram-minus');
			  });
			TV
		}
	end

	def render_homepage_flash
		height = 166
		width = 197
		div(:id => "flashplayer-#{object_id}", :style => "height:#{height}px;width:#{width}px;position:absolute;top:90px;left:12px;"){}
		rawtext <<-cdn
<!-- load script for creating Flowplayer -->
<script type="text/javascript" src="/flowplayer/3dcdn/3dcdn.loader.js"></script>

<!-- load script for Analyzer -->
<script type="text/javascript" src="/flowplayer/3dcdn/3dcdn.analyzer.kabala.js"></script>
	cdn
		javascript {
			rawtext <<-Embedjs
				$(document).ready(function() {
						$('#home-kabtv #kabtv-top').height(270);
						var varAnalyzerID = "#{get_analyzer_id}";
						var cdn_ClipURL =  "#{get_smil_url}";
						$('#home-kabtv #kabtv-top').height(270);
						 objPlayer = $f('flashplayer-#{object_id}',
                {src:'/flowplayer/3dcdn/3Dcdn.player.swf', version: [10, 0], cachebusting: $.browser.msie},
                {
								key:'#\@932a7f91ab5747d7f90',
								canvas: { 
									backgroundImage: 'url(/flowplayer/logo-10sec-homepage.swf)'
								},
								clip:{
									autoBuffering: 'true',
									autoPlay: 'true',
									provider: 'cdn',
									onStart: function() { 
											this.mute(); 
									} 
								},
								onBeforePause: function() { 
										return false; 
								},
								plugins: {
									controls: {
										all: false,
										volume: true,
										fullscreen: true,
										stop: true,
										mute: true
									},
									cdn: {
										host: varPostURL,
										playerId: varPlayerID,
										ownerId: varAnalyzerID,
										smilUrl: cdn_ClipURL,
										eventTarget: varIvivoPostURL,
                    bwDetect: false,
                    bwUseSO: false 
									}
								}
						 });
			});
			addOnBeforeunloadEvent(sendLogoffEvent);
			Embedjs
		}
	end

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

  def ask_button_only
    div(:class => 'button_l') {
			input(:id => 'ask_btn2', :type => "button", :value => _(:ask_question),
						:title => _(:ask_question), :name => "subscribe", :class => "button",
						:alt => _(:ask_question))
		}
	end

  def ask_button_and_form
    div(:class => 'button_c') {
			input(:id => 'ask_btn1', :type => "button", :value => _(:ask_question),
						:title => _(:ask_question), :name => "subscribe", :class => "button",
						:alt => _(:ask_question))
		}
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
              label(:class => 'ta-label', :for => 'options_qquestion') {
								rawtext _(:questions)
								rawtext ':'
							}
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
        #HEB-17 div(:class => 'hdr'){ rawtext _(:broadcasting_now)}
        format_item(item)
        #HEB-17 div(:class => 'hdr'){ rawtext _(:future_programs)}
        found = true
      end
    }
  end

  def format_item(item)
    time = sprintf("%02d:%02d",
      item.start_time / 100,
      item.start_time % 100)
    title = item.title.gsub '[\r\n]', ''
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
