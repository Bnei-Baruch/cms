// Download lessons
$(function() {
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

// TV and Radio players.
var $play_radio;
var $stop_radio;
var $play_tv;
var $stop_tv;
$(function() {
    $play_radio = $('.radio .play');
    $stop_radio = $('.radio .stop');
    $play_tv = $('.tv .play');
    $stop_tv = $('.tv .stop');
});

// State of player
var playState_radio = false;
var playState_tv = false;

// Radio-TV tab creation
$(function() {
    $("#radio-TV > ul").tabs({
        selected: 0,
        show:
            // On switch between tabs...
        function(tab){
            if (tab.tab.hash == "#tv"){
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
});

//Radio player management
$(function() {
  // Radio
  $play_radio.click(function(event){
    event.preventDefault();
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

// Video gallery
// Homepage
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
  var $sitemap = $('.sitemap');
  if ($sitemap.size() == 0) {return};
  $sitemap.corner({
          tl:{radius: 8},
          tr:{radius: 8},
          bl:{radius: 8},
          br:{radius: 8},
          antiAlias:true
  });
});
  
// Inner page
var playerConfig_innerpage = { 
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
  var id = $player.attr("target_id");
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
  });
  $("#flashplayer-"+id+" img").click(function(){
      $($links[0]).trigger('click'); 
  });
  $(".inner-player ul li:nth-child(odd)").addClass("odd");
});


