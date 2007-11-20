/**
 * This script contains embed functions for common plugins. This scripts are complety free to use for any purpose.
 */

function writeFlash(p) {
	writeEmbed(
		'D27CDB6E-AE6D-11cf-96B8-444553540000',
		'http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=6,0,40,0',
		'application/x-shockwave-flash',
		p,
		false
	);
}

function writeShockWave(p) {
	writeEmbed(
	'166B1BCA-3F9C-11CF-8075-444553540000',
	'http://download.macromedia.com/pub/shockwave/cabs/director/sw.cab#version=8,5,1,0',
	'application/x-director',
		p,
		false
	);
}

function writeQuickTime(p) {
	writeEmbed(
		'02BF25D5-8C17-4B23-BC80-D3488ABDDC6B',
		'http://www.apple.com/qtactivex/qtplugin.cab#version=6,0,2,0',
		'video/quicktime',
		p,
		false
	);
}

function writeRealMedia(p) {
	writeEmbed(
		'CFCDAA03-8BE4-11cf-B84B-0020AFBBCCFA',
		'http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=6,0,40,0',
		'audio/x-pn-realaudio-plugin',
		p,
		false
	);
}

function writeWindowsMedia(p) {
	p.url = p.src;
	writeEmbed(
		'6BF52A52-394A-11D3-B153-00C04F79FAA6',
		'http://activex.microsoft.com/activex/controls/mplayer/en/nsmp2inf.cab#Version=5,1,52,701',
		'application/x-mplayer2',
		p,
		true
	);
}

function writeEmbed(cls, cb, mt, p, c) {
	var h = '', n, x, e;

	h += '<object classid="clsid:' + cls + '" codebase="' + cb + '"';
	h += typeof(p.id) != "undefined" ? ' id="' + p.id + '"' : '';
	h += typeof(p.name) != "undefined" ? ' name="' + p.name + '"' : '';
	h += typeof(p.width) != "undefined" ? ' width="' + p.width + '"' : '';
	h += typeof(p.height) != "undefined" ? ' height="' + p.height + '"' : '';
	h += typeof(p.align) != "undefined" ? ' align="' + p.align + '"' : '';
	h += ' type="' + mt + '"';
	h += '>';

	e = '';
	for (n in p){
		if (c){
			x = (p[n] == true) ? 1 : (p[n] == false) ? 0 : p[n];
		}else{
			x = p[n];
		}
		h += '<param name="' + n + '" value="' + x + '">';
		e += n + '="' + x + '" ';
	}

	h += '<embed type="' + mt + '"';
	h += e;
	h += '></embed></object>';

	document.write(h);
}

// For our internal needs :)
function SetColor(me, sel, out){// Set current player selected
  // reset all
  var div = me;
  while (div.id != 'right-list'){
      div = div.parentNode;
  }
  var divs = div.getElementsByTagName('div');
  for (d in divs){
    if (divs[d].className == 'right-img') divs[d].style.backgroundColor = out;
  }
  // color myself
  div = me;
  while (div.className != 'right-item'){
      div = div.parentNode;
  }
  var divs = div.getElementsByTagName('div');
  for (d in divs){
    if (divs[d].className == 'right-img'){
      divs[d].style.backgroundColor = sel;
        return;
    }
  }
}
function CreateControl(DivID, url, autoStart, width, height, uimode){
  var d = document.getElementById(DivID);
  if (d == null) return;
  if (typeof width == "undefined") {
    width = "380";
  }
  if (typeof height == "undefined") {
    height = "356";
  }
  if (typeof uimode == "undefined") {
    uimode = "full";
  }
  d.innerHTML = 
    '<object class="object" id="MediaPlayer" classid="CLSID:6BF52A52-394A-11D3-B153-00C04F79FAA6" standby="Loading Windows Media Player components..." type="application/x-oleobject" width="'+width+'" height="'+height+'"> <param name="url" value="' + url + '" /> <param name="autostart" value="' +autoStart+'" /> <param name="uimode" value="'+uimode+'" /> <param name="stretchToFit" value="true" /> <embed src="' + url + '" type="application/x-mplayer2" pluginspage="http://activex.microsoft.com/activex/controls/mplayer/en/nsmp2inf.cab#Version=6,4,7,1112" width="'+width+'" height="'+height+'" autostart="'+autoStart+'" uimode="'+uimode+'" /> </object>';
}

function fullScreen(player){
   if (player.playState == 3) {
      alert(fullScreenMessageNote);
      player.fullScreen = true
   } else {
      alert(fullScreenMessageErr);
   }
}
