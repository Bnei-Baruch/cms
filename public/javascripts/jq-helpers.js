// Download lessons
$(function() {
    $(".toggle").click(function(event){
        event.preventDefault();
        $this = $(this);
        $ul = $("#lesson-" + $this.attr("tree_node"));
        $img = $this.find("img");
        if ($ul.css("display") == "none"){
            $ul.show("slow");
            $img.removeClass("x-tree-elbow-plus");
            $img.addClass("x-tree-elbow-minus");
        } else {
            $ul.hide("slow");
            $img.removeClass("x-tree-elbow-minus");
            $img.addClass("x-tree-elbow-plus");
        }
    });
    $(".toggle").hover(
    function(){
        $(this).toggleClass("x-tree-ec-over");
    },
    function(){
        $(this).toggleClass("x-tree-ec-over");
    }
);
});

var $play;
var $stop;
var playState = false;
$(function() {
    $play = $('.radio .play');
    $stop = $('.radio .stop');
});

// Radio-TV tab
$(function() {
    $("#radio-TV > ul").tabs({
        selected: 0,
        show:
            function(tab){
            if (tab.tab.hash == "#tv"){
                stopPlayer("radioplayer");
                playState = false;
                $play.removeClass("play-in");
                $play.addClass("play-out");
                startPlayer("tvplayer");
            } else {
                stopPlayer("tvplayer");
            }
        }
    });
});

//Radio player management
$(function() {
    $play.click(function(event){
        event.preventDefault();
        if (!playState) {
            startPlayer('radioplayer');
            playState = true;
        }
    });
    $play.hover(
    function(){
        if (!playState) {
            $(this).removeClass("play-out");
            $(this).addClass("play-in");
        }
    },
    function(){
        if (!playState) {
            $(this).removeClass("play-in");
            $(this).addClass("play-out");
        }
    }
);
    $stop.click(function(event){
        event.preventDefault();
        if (playState) {
            stopPlayer('radioplayer');
            playState = false;
            $play.removeClass("play-in");
            $play.addClass("play-out");
        }
    });
    $stop.hover(
    function(){
        $(this).removeClass("stop-out");
        $(this).addClass("stop-in");
    },
    function(){
        $(this).removeClass("stop-in");
        $(this).addClass("stop-out");
    }
);
});

// Radio-TV buttons
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
