$(document).ready(function() { 

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


    //************************************
    // Campus Form
    //************************************
    // pre-submit callback 
    function showRequest(formData, jqForm, options) { 
        var queryString = $.param(formData); 
        var emailRegEx = /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i;
        if (formData[1].value.search(emailRegEx) == -1) {
            alert("כתובת הדואר האלקארונית לא תקינה");
            return false;
        }
        return true; 
    } 
 
    // post-submit callback 
    function showResponse(responseText, statusText)  { 
        var options = { 
            target:        '#output2',
            beforeSubmit:  showRequest,  
            success:       showResponse, 
            resetForm: true    
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

    $("a.hide-player").hide();
    $("a.show-player").hide();

    $("a.media").click(function(event){
        event.preventDefault();
        $this = $(this);
        $this.parents('.mediacasting').children("a.hide-player").toggle();
        $this.removeClass('media');
        $this.addClass('mediaplayer');
        $this.media({autoplay: true});
        
    });
    
    $("a.hide-player").click(function(event){
        event.preventDefault();
        $this = $(this);
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
        var player = $this.parents('.mediacasting').find("object");
        if (player && player[0] && player[0].controls && player[0].controls.isAvailable('Start')) {
            player[0].controls.start();
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
    var id = $player.attr("target_id");
    if (id == 0) return;
    var $links = $player.find("a").not(".more").click(function(event){
        event.preventDefault();
        playerConfig_homepage.videoFile = $(this).attr("href");
        if (flowplayer_homepage == null) {
            flowplayer_homepage = flashembed("flashplayer-"+id,  
            {src:"/flowplayer/FlowPlayerLight.swf", bgcolor:'#F0F4FD',width:226, height:169},
            {config: playerConfig_homepage} 
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
    if ($sitemap.size() == 0) {return;}
    $sitemap.corner({
        tl:{radius: 8},
        tr:{radius: 8},
        bl:{radius: 8},
        br:{radius: 8},
        antiAlias:true
    });

    $sitemap = $('.sitemap-inner');
    if ($sitemap.size() == 0) {return;}
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
    controlBarBackgroundColor: -1,
    controlBarGloss: 'low',
    showMenu:false
};
var flowplayer_innerpage = null;
var now_playing = null;

$(function() {
    var $player = $('.inner-player')
    if ($player.size() == 0) return;
    $player.corner({
        tl:{radius: 8},
        tr:{radius: 8},
        bl:{radius: 8},
        br:{radius: 8},
        antiAlias:true
    });
    var id = $player.attr("rel");
    if (id == 0) return;

    var $links = $player.find("a").not(".more").click(function(event){
        event.preventDefault();
        playerConfig_innerpage.videoFile = $(this).attr("href");
        if (flowplayer_innerpage == null) {
            flowplayer_innerpage = flashembed("flashplayer-"+id,
            {src:"/flowplayer/FlowPlayerLight.swf", bgcolor:'#F0F4FD',width:503, height:378},
            {config: playerConfig_innerpage}
        );
        } else {     
            flowplayer_innerpage.setConfig(playerConfig_innerpage);
        }
    
        if (now_playing) now_playing.toggleClass("playing");
        now_playing = $(this).parent();
        now_playing.toggleClass("playing");
        // Find out and replace title
        var $this = $(this);
        var hdr = $($(this).parent().children('.h1-play')[0]).text();
        $(this).parents('.inner-player').find('.play-title').text(hdr);
        return false;
    });
    $("#flashplayer-"+id+" img").click(function(){
        $($links[0]).trigger('click'); 
    });
    $(".inner-player ul li:nth-child(odd)").addClass("odd");
});

