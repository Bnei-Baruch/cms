//comment
$(document).ready(function() { 
    function before_admin_comment_post(formData, jqForm, options) {
        var queryString = $.param(formData);
        $('.admin_comment_main #submit').replaceWith("<div id='loader'>&nbsp;&nbsp;<img class='tshuptshik' alt='Loading' src='/images/ajax-loader.gif'></div>");
        return true;
    }
    function after_admin_comment_post(responseText, statusText){
    // null
    }
    var options = {
        target:       '#admin_comment_form',   // target element(s) to be updated with server response
        beforeSubmit:  before_admin_comment_post,
        success:       after_admin_comment_post,
        resetForm: true    ,
        clearForm: true   // clear all form fields after successful submit
    };
    $('#admin_comment_form').submit(function() {
        $(this).ajaxSubmit(options);
        return false;
    });
});


// picture gallery
$(document).ready(function() { 
    if (jQuery.isFunction($('a.gallery').lightbox)){
        $('a.gallery').lightbox({
            overlayBgColor: '#FFF',
            overlayOpacity: 0.8,
            containerResizeSpeed: 350,
            fileBottomNavCloseImage : '/images/closelabel-heb.gif',
            strings : {
                prevLinkTitle: 'תמונה הקודמת',
                nextLinkTitle: 'תמונה הבא ',
                prevLinkText:  ' &laquo; קודם ',
                nextLinkText:  ' הבא &raquo; ',
                closeTitle: 'סגור',
                image: '',
                of: ' / '
            }
        });
    }
});


// form sending email - for manpower form
$(document).ready(function() { 
    $('#success').hide();
    var manpower_ajax_form_options = {
        target: '#img_loader',
        timeout:   30000,
        beforeSubmit: b4_manpower,
        success: after_manpower
    };
  
    if (jQuery.isFunction($('#manpower_form').ajaxForm)){
        $('#manpower_form').ajaxForm(manpower_ajax_form_options);
    }
  
});

function b4_manpower(formData, jqForm, options) { 
    var queryString = $.param(formData);
    var emailRegEx = /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i;
    if (formData[1].value.search(emailRegEx) == -1) {
        alert("כתובת הדואר האלקארונית לא תקינה");
        return false;
    }
  
    if (formData[0].value == '' || formData[2].value == '' ||
        formData[5].value == '' || formData[6].value == '' ||
        formData[7].value == '' || formData[12].value == '' ||
        formData[13].value == ''  ){
        alert('יש להזין את כל השדות עם כוכבית');
        $('.must').addClass('emptyfield');
        return false;
    }

    $('.manpower').append("<img id='img_loader' align='center' src='/images/bar-loader.gif'>")
    return true;
}


function after_manpower(responseText, statusText){
    $('#img_loader').hide();
    $('#success').fadeIn('slow');
    setTimeout(function(){
        $('#success').fadeOut("slow");
    }, 5000);
    $('#manpower_form').resetForm();
    $('.must').removeClass('emptyfield');
}


// Send to friend form
$(document).ready(function() { 
    $("#friend_form").hide();
    $("#closed_friend").click(function(){
        $("#friend_form").show();
        $("#closed_friend").hide();
    });
    $("#stf_cancel").click(function(){
        $("#friend_form").hide();
        $("#closed_friend").show();
    });
  
  
    //toggler is toggling the state of the 'send to friend' form
    $("#friend_form").submit(function(event){
        event.preventDefault();
        var inputs = [];
        var is_ok = true;
        $(':input', this).each(function(){
            var emailRegEx = /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i;
            var field_name = $(this).attr('name');
            if (field_name == 'adresseto' && this.value.search(emailRegEx) == -1) {
                alert("כתובת הדואר האלקטרוני לא תקינה");
                is_ok = false;
                return false;
            }
            if (!is_ok) return false;
            if (field_name == 'adressefrom' && this.value.search(emailRegEx) == -1) {
                alert("כתובת השולח אינה תקינה");
                is_ok = false;
                return false;
            }
            if (field_name != 'submit'){
                inputs.push(field_name + '=' + encodeURIComponent(this.value));
            }
        });
        if (!is_ok) return false;
        $("#friend h1").append("<span id='loader'>&nbsp;&nbsp;<img class='tshuptshik' alt='Loading' src='/images/ajax-loader.gif'></span>");
        jQuery.ajax({
            data: inputs.join('&'),
            url: this.action,
            timeout: 60000,
            success: after_send_to_friend()
        });
    
        return false;
    }) //end of submit
})
function after_send_to_friend(){
    $("#friend_form").resetForm();
    $("#friend_form #loader").remove();
    $("#friend_form").hide();
    $("#closed_friend").show();
    alert('נשלח בהצלחה!');
}



//*****************************
// Comment system
//*****************************

$(document).ready(function(){
  
    $("#comment_form").hide();
    $("#comment_form").hover(function(){
        $(this).addClass('pretty-hover');
    }, function(){
        $(this).removeClass('pretty-hover');
    });
  
    $(".comment_clickable").hover(function(){
        $(this).addClass('pretty-hover');
    }, function(){
        $(this).removeClass('pretty-hover');
    });
    
    $(".link_comment").hover(function(){
        $(this).addClass('pretty-hover');
    }, function(){
        $(this).removeClass('pretty-hover');
    });
  
  
    $("#comment_form #cancel").click(function(){
        $("#loader").replaceWith("<input type=\"submit\" value=\"שלח\" name=\"Submit\" id=\"submit\" class=\"submit\"/>");
        $("#comment_form").hide();
        $("#closed_comment").show();
    });
  
    $("#closed_comment").click(function(){
        $("#comment_form").show();
        $("#closed_comment").hide();
    });
  
    $(".comment_title").click(function(){
        $this = $(this);
        $this.parents('.comment_item').children(".comment_body").toggle();
    });
 
    function before_comment_post(formData, jqForm, options) {
        var queryString = $.param(formData);
        // var emailRegEx = /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i;
        // if (formData[1].value.search(emailRegEx) == -1) {
        //   alert("כתובת הדואר האלקטרוני לא תקינה");
        //   return false;
        // }
      
        $('.create_comment #submit').replaceWith("<div id='loader'>&nbsp;&nbsp;<img class='tshuptshik' alt='Loading' src='/images/ajax-loader.gif'></div>");
      
        return true;
    } 
    
    // post-submit callback 
    function after_comment_post(responseText, statusText)  { 
        var options = {
            target:        '#comment_form',
            beforeSubmit:  before_comment_post,
            success:       after_comment_post,
            resetForm: true    ,
            clearForm: true        // clear all form fields after successful submit
        };
      
        $("#reactions").hide();
      
        $('#yellow_effect').fadeOut(10000, function(){
            $(this).remove();
            $("#comment_form").hide();
            $("#closed_comment").show();
            $("#reactions").show();
        });
      
    //       $('#comment_form').submit(function() {
    //        $(this).ajaxSubmit(options);
    //        return false;
    //        });
    } 
    
    var options = { 
        target:        '#comment_form',   // target element(s) to be updated with server response
        beforeSubmit:  before_comment_post,  // pre-submit callback
        success:       after_comment_post,  // post-submit callback
        resetForm: true    ,
        clearForm: true        // clear all form fields after successful submit
      
    };
    
    $('#comment_form').submit(function() { 
        $(this).ajaxSubmit(options);
        return false;
    });
  
});



//*****************************************
//This bit of code is
//actually managing the campus submit form
//******************************************
$(document).ready(function() { 
  
    if (typeof loadCaptcha == "function"){
        loadCaptcha();
    }
    //************************************
    // Media RSS, lessons_show_in_table
    //************************************
    $(function(){
        $(".mouse-grey-over").hover(
            function(){
                $(this).toggleClass("grey-over");
            },
            function(){
                $(this).toggleClass("grey-over");
            })
    });
    $(function() {
        $('.media_rss a').attr('target', '_blank');
    });


    
    
    //************************************
    // Campus Form
    // ************************************
    // pre-submit callback 
    function showRequest(formData, jqForm, options) { 
        var queryString = $.param(formData);
        var emailRegEx = /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i;
        if (formData[1].value.search(emailRegEx) == -1) {
            alert("כתובת הדואר האלקטרוני לא תקינה");
            return false;
        }
      
        $('.campus .submit').replaceWith("<div id='loader'>&nbsp;&nbsp;<img class='tshuptshik' alt='Loading' src='/images/ajax-loader.gif'></div>");
      
        return true;
    } 
    
    // post-submit callback 
    function showResponse(responseText, statusText)  { 
        var options = {
            target:        '#output2',
            beforeSubmit:  showRequest,
            success:       showResponse,
            resetForm: true    ,
            clearForm: true        // clear all form fields after successful submit
        };
      
        $('#myForm2').submit(function() {
            $(this).ajaxSubmit(options);
            return false;
        });
      
    } 
    
    var options = { 
        target:        '#output2',   // target element(s) to be updated with server response
        beforeSubmit:  showRequest,  // pre-submit callback
        success:       showResponse,  // post-submit callback
        resetForm: true    ,
        clearForm: true        // clear all form fields after successful submit
      
    };
    
    $('#myForm2').submit(function() { 
        $(this).ajaxSubmit(options);
      
        // !!! Important !!!
        // always return false to prevent standard browser submit and page navigation
        return false;
    }); 
    
    //************************************
    // Download lessons
    //************************************
    $(".toggle").click(function(event){
        event.preventDefault();
        $this = $(this);
        $ul = $("#lesson-" + $this.attr("tree_node"));
        $img = $this.find("img");
        if ($ul.css("display") == "none"){
            $ul.show("slow");
            $img.removeClass("x-plus").addClass("x-minus");
        } else {
            $ul.hide("slow");
            $img.removeClass("x-minus").addClass("x-plus");
        }
    });
    $(".toggle").hover(
        function(){
            $(this).toggleClass("x-over");
        },
        function(){
            $(this).toggleClass("x-over");
        }
        );
});


//************************************
// TV and Radio players.
//************************************
var $play_radio;
var $stop_radio;
var $play_tv;
var $stop_tv;
// State of player
var playState_radio = false;
var playState_tv = false;

$(function() {
    $play_radio = $('.radio .play');
    $stop_radio = $('.radio .stop');
    $play_tv = $('.tv .play');
    $stop_tv = $('.tv .stop');
  
    // Radio-TV tab creation
    $("#radio-TV > ul").tabs({
        selected: 0,
        show:
        // On switch between tabs...
        function(tab){
            if (tab.hash == "#tv"){
                stopPlayer("radioplayer");
                playState_radio = false;
                $play_radio.removeClass("play-in").addClass("play-out");
                startPlayer("tvplayer");
                playState_tv = true;
            } else {
                stopPlayer("tvplayer");
            }
        }
    });
    $a = $('#tv a#full_screen');
    $a.click(function(event){
        event.preventDefault();
        gofs("tvplayer");
    });

    $rpp = $('.radio .play');
    $rpp.click(function(event){
        event.preventDefault();
        rppl("radioplayer");
        return false;
    });

    //************************************
    // Media player(s) on inner page
    //************************************

    // Previous form - please do not remove for now - thanks
    //$('.mediacasting').filter(function(){
    //  return ($(this).find('.media').attr('href')).search('mp3') == -1
    //}).addClass('video');


    //$('.mediacasting').last.css('border-bottom','0px none #E8E8E8')
    
    //$('.mediacasting').prev().css('border-bottom','0px none #E8E8E8');
    var item = $('.mediacasting').prev();
    item.css('border-bottom','0px none #E8E8E8');
    $('.mediacasting:has(.media[href*=mp3])').addClass('audio');
    $('.mediacasting:not(:has(.media[href*=mp3]))').addClass('video');

    $("a.hide-player").hide();
    $("a.show-player").hide();

    $("a.media").click(function(event){
        event.preventDefault();
        $this = $(this);
        $this.parents('.mediacasting').children("a.hide-player").toggle();
        $this.parents('.audio').css('background-image', 'url(../images/blank.gif)');
        $this.parents('.video').css('background-image', 'url(../images/blank.gif)');
        $this.removeClass('media');
        $this.addClass('mediaplayer');
        $this.media({
            autoplay: true
        });
  
    });

    $("a.hide-player").click(function(event){
        event.preventDefault();
        $this = $(this);
        $this.parents('.audio').css('background-image', 'url(/images/hebmain/audio.png)');
        $this.parents('.video').css('background-image', 'url(/images/hebmain/video.png)');
        $this.toggle();
        $this.siblings().toggle();
        var player = $this.parents('.mediacasting').find("object");
        if (player && player[0] && player[0].controls && player[0].controls.isAvailable('Stop')) {
            player[0].controls.stop();
        }
        if (player && player[0]){
            player[0].SetVariable('closePlayer', 1);
        }
    });

    $("a.show-player").click(function(event){
        event.preventDefault();
        $this = $(this);
        $this.toggle();
        $this.siblings().toggle();
        $this.parents('.audio').css('background-image', 'url(../images/blank.gif)');
        $this.parents('.video').css('background-image', 'url(../images/blank.gif)');
  
        var player = $this.parents('.mediacasting').find("object");
        if (player && player[0] && player[0].controls && player[0].controls.isAvailable('Start')) {
            player[0].controls.start();
        }
        if (player && player[0]){
            player[0].SetVariable('closePlayer', 0);
        }
    });

    //************************************
    //Radio player management
    //************************************
    $play_radio.click(function(event){
        event.preventDefault();
        rppl("radioplayer");
        return false;
        if (!playState_radio) {
            startPlayer('radioplayer');
            playState_radio = true;
        }
    });
    $play_radio.hover(
        function(){
            if (!playState_radio) {
                $(this).removeClass("play-out").addClass("play-in");
            }
        },
        function(){
            if (!playState_radio) {
                $(this).removeClass("play-in").addClass("play-out");
            }
        }
        );
    $stop_radio.click(function(event){
        event.preventDefault();
        if (playState_radio) {
            stopPlayer('radioplayer');
            playState_radio = false;
            $play_radio.removeClass("play-in").addClass("play-out");
        }
    });
    $stop_radio.hover(
        function(){
            $(this).removeClass("stop-out").addClass("stop-in");
        },
        function(){
            $(this).removeClass("stop-in").addClass("stop-out");
        }
        );
    // TV
    $play_tv.click(function(event){
        event.preventDefault();
        if (!playState_tv) {
            startPlayer('tvplayer');
            playState_tv = true;
        }
    });
    $play_tv.hover(
        function(){
            if (!playState_tv) {
                $(this).removeClass("play-out").addClass("play-in");
            }
        },
        function(){
            if (!playState_tv) {
                $(this).removeClass("play-in").addClass("play-out");
            }
        }
        );
    $stop_tv.click(function(event){
        event.preventDefault();
        if (playState_tv) {
            stopPlayer('tvplayer');
            playState_tv = false;
            $play_tv.removeClass("play-in").addClass("play-out");
        }
    });
    $stop_tv.hover(
        function(){
            $(this).removeClass("stop-out").addClass("stop-in");
        },
        function(){
            $(this).removeClass("stop-in").addClass("stop-out");
        }
        );
});

// Start/stop functions
function startPlayer(id){
    var player = document.getElementById(id);
    if (player && player.controls && player.controls.isAvailable('Play')){
        player.controls.play();
    }
}
function pausePlayer(id){
    var player = document.getElementById(id);
    if (player && player.controls && player.controls.isAvailable('Pause')) {
        player.controls.pause();
    }
}
function stopPlayer(id){
    var player = document.getElementById(id);
    if (player && player.controls && player.controls.isAvailable('Stop')) {
        player.controls.stop();
    }
}

var fs_str = 'ESC ליציאה ממצב "מסך מלא" לחץ על';
var nofs_str = 'נא להפעיל נגנ ע"מ לצפותו במסך מלא';
function gofs(id){
    var player = document.getElementById(id);
    if (player && player.playState == 3) {
        alert(fs_str);
        player.fullScreen = 'true';
    } else {
        alert(nofs_str);
    }
}
function rppl(id){
    var player = document.getElementById(id);
    if (player && jQuery.browser.ie && player.URL){
        stopPlayer(id);
        player.openPlayer(player.URL);
    }
    else if (player && player.src && player.openPlayer) {
        stopPlayer(id);
        player.openPlayer(player.src);
    } else if (player){
        startPlayer(id);
    }
    return false;
}


//************************************
// Video gallery
// Homepage
//************************************
var playerConfig_homepage = { 
    autoPlay: true,
    loop: false,
    initialScale:'scale',
    useNativeFullScreen: true,
    showStopButton:false,
    autoRewind:true,
    showVolumeSlider: false,
    showFullScreenButton:false,
    controlsOverVideo: 'ease',
    controlBarBackgroundColor: -1,
    controlBarGloss: 'low',
    showMenu:false
};
var flowplayer_homepage = null;
$(function() {
    var $player = $('.player');
    if ($player.size() == 0) return;
    var id = $player.attr("id");
    if (id == 0) return;
    var $links = $player.find("a").not(".more").click(function(event){
        event.preventDefault();
        playerConfig_homepage.videoFile = $(this).attr("href");
        if (flowplayer_homepage == null) {
            flowplayer_homepage = flashembed("flashplayer-"+id,
            {
                src:"/flowplayer/FlowPlayerLight.swf",
                bgcolor:'#F0F4FD',
                width:226,
                height:169
            },

            {
                config: playerConfig_homepage
            }
            );
        } else {
            flowplayer_homepage.setConfig(playerConfig_homepage);
        }
    });
    $("#flashplayer-"+id+" img").click(function(){
        $($links[0]).trigger('click');
    });
});

$(function() {
    //************************************
    // Sitemap
    //************************************
    var $sitemap = $('.sitemap');
    if ($sitemap.size() == 0) {
        return;
    }
    $sitemap.corner({
        tl:{
            radius: 8
        },
        tr:{
            radius: 8
        },
        bl:{
            radius: 8
        },
        br:{
            radius: 8
        },
        antiAlias:true
    });
  
    $sitemap = $('.sitemap-inner');
    if ($sitemap.size() == 0) {
        return;
    }
    if ($.browser.ie) {
        if ($.browser.versionNumber == 7) {
            $sitemap.parent().css("width", "100%");
        }
    } else {
        $sitemap.parent().css("float", "right");
    }
});

//************************************
// Inner page
//************************************
var playerConfig_innerpage = { 
    autoPlay: true,
    loop: false,
    initialScale:'scale',
    useNativeFullScreen: true,
    showStopButton:false,
    autoRewind:true,
    showVolumeSlider: true,
    showFullScreenButton:false,
    controlsOverVideo: 'ease',
    controlBarBackgroundColor:0xe9e9e9,
    controlBarGloss: 'low',
    showMenu:false
};
var flowplayer_innerpage = null;
var now_playing = null;

$(function() {
    var $player = $('.inner-player')
    if ($player.size() == 0) return;
    $player.corner({
        tl:{
            radius: 8
        },
        tr:{
            radius: 8
        },
        bl:{
            radius: 8
        },
        br:{
            radius: 8
        },
        antiAlias:true
    });
    var id = $player.attr("id").replace('id-', '');
    if (id == 0) return;
  
    var $links = $player.find("a").not(".more").click(function(event){
        var $this = $(this);
        event.preventDefault();
        playerConfig_innerpage.videoFile = $this.attr("href");
        if (flowplayer_innerpage == null) {
            flowplayer_innerpage = flashembed("flashplayer-"+id,
            {
                src:"/flowplayer/FlowPlayerLight.swf",
                bgcolor:'#F0F4FD',
                width:503,
                height:378
            },

            {
                config: playerConfig_innerpage
            }
            );
        } else {
            flowplayer_innerpage.setConfig(playerConfig_innerpage);
        }
        window.onClipDone = function() {
            var next = now_playing.next();
            if (next.length == 0){
                next = $($links[0]).parent();
            }
            next.find('a.h1-play').click();
        };
  
        if (now_playing) now_playing.toggleClass("playing");
        now_playing = $this.parent();
        now_playing.toggleClass("playing");
        // Find out and replace title
        var hdr = $($this.parent().children('.h1-play')[0]).text();
        $this.parents('.inner-player').find('.play-title').text(hdr);
        return false;
    });
    $("#flashplayer-"+id+" img").click(function(){
        $($links[0]).trigger('click');
    });
    $(".play-list-button").click(function(){
        $($links[0]).trigger('click');
    });
    $(".inner-player ul li:nth-child(odd)").addClass("odd");
});


//***************************************
// Audio Player with a playlist 
//***************************************
var playerConfig_playlist = { 
    autoPlay: true,
    videoHeight:0,
    loop: true,
    initialScale:'scale',
    useNativeFullScreen: true,
    showStopButton:false,
    autoRewind:true,
    showVolumeSlider: true,
    showFullScreenButton:false,
    controlsOverVideo: 'locked',
    controlBarBackgroundColor:0xe9e9e9,
    controlBarGloss: 'low',
    showMenu:false
};
$(function() {
    var audio = [];
    $('.playlist-player').each(function(){
        var $this = $(this);
        var id = $this.attr("id").replace('id-', '');
        if (id == 0) return;
        $this.corner({
            tl:{
                radius: 8
            },
            tr:{
                radius: 8
            },
            bl:{
                radius: 8
            },
            br:{
                radius: 8
            },
            antiAlias:true
        });
        var player = flashembed("flashplayer-"+id,
        {
            src:"/flowplayer/FlowPlayerLight.swf",
            bgcolor:'#F0F4FD',
            width:503,
            height:50
        },

        {
            config: playerConfig_playlist
        }
        );
        audio.push(player);
        var now_playing = null;
        var $links = $this.find("a").click(function(event){
            var $this = $(this);
            event.preventDefault();
            window.onClipDone = function() {
                var next = now_playing.next();
                if (next.length == 0){
                    next = $($links[0]).parent();
                }
                next.find('a.h1-play').click();
            };
            jQuery.each(audio, function(index, value) {
                value.Pause();
            });
            if (now_playing){
                now_playing.toggleClass("playing");
            }
            now_playing = $this.parent();
            now_playing.toggleClass("playing");
            playerConfig_playlist.videoFile = $this.attr("href");
            player.setConfig(playerConfig_playlist);
            // Find out and replace title
            var hdr = $this.text();
            $this.parents('.playlist-player').find('.play-title').text(hdr);
            return false;
        });
        $(".playlist-player ul li:nth-child(odd)").addClass("odd");
        $(".playlist-player ul li a").hover(
            function () {
                $(this).css("color", "#0D47B2");
            },
            function () {
                $(this).css("color", "black");
            }
            );
    })
});

$(function() {
    $('a.target_blank').attr('target', '_blank');
});

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
    if (typeof reloadSchedule == "function") {
        reloadSchedule();
    }
    if (typeof currentProgram == "function") {
        currentProgram();
        setInterval(currentProgram, 300000);
    }
    if (typeof $.livequery == "function") {
        $("a.schedule_menu_item").livequery('click',function () {
            $("div.schedule_day").hide();
            $("#schedule_list div#D_" + this.id).show();
            $("a.schedule_menu_item").removeClass('schedule_selected');
            $(this).toggleClass('schedule_selected');
            return false;
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
        $("#kabtv #kabtv-loading").show();
        $(this).ajaxSubmit(function(responseText, statusText){
            $("#kabtv #kabtv-loading").hide();
            alert(responseText);
            $("#kabtv #ask_question").hide();
            $("#kabtv #q").show();
            $("#kabtv #ask_btn").show();

        });
        // always return false to prevent standard browser submit and page navigation
        return false;
    });

});
