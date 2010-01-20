var revision = "$LastChangedRevision: 2522 $";
var varPostURL = "/php/Analyzer.Proxy.PHP.php";
var varIvivoPostURL = 'http://www.ivivo.net/Tools/StateWMP.asp';
var varPlayerID = GeneratePlayerID();

function GeneratePlayerID() {
    if (readCookie("FLPlayerID") != null) return readCookie("FLPlayerID");
    var d, s = "";
    d = Math.round(Math.random() * 100000000);
    s = d.toString();
    if (s.length > 8) {
        s = s.substring(0, 8);
    } else {
        while (s.length < 8) {
            s = "0" + s;
        }
    }

    createCookie("FLPlayerID", "FL" + s, 365);
    return "FL" + s;
}

function readCookie(name) {
    var nameEQ = name + "=";
    var ca = document.cookie.split(';');
    for (var i = 0; i < ca.length; i++) {
        var c = ca[i];
        while (c.charAt(0) == ' ') c = c.substring(1, c.length);
        if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length, c.length);
    }
    return null;
}

function createCookie(name, value, days) {
    if (days) {
        var date = new Date();
        date.setTime(date.getTime() + (days * 24 * 60 * 60 * 1000));
        var expires = "; expires=" + date.toGMTString();
    }
    else var expires = "";
    document.cookie = name + "=" + value + expires + "; path=/";
}

// Add event into window.onbeforeunload
function addOnBeforeunloadEvent(func) {
	try {
		var oldonbeforeunload = window.onbeforeunload;
		if (typeof window.onbeforeunload != 'function') {
			window.onbeforeunload = func;
		} else {
			window.onbeforeunload = function() {
				func();
				if (oldonbeforeunload) {
					oldonbeforeunload();
				}
			}
		}
	} catch (e) {
	}
}

function sendLogoffEvent() {

	var sEvent = null;
	try {
		sEvent = $f()._api().fp_getLogoffEvent();
	} catch (e) {return;}

	if (null != sEvent || undefined != sEvent || 0 < sEvent.length) {
		try {
			g_xhrRequest = new XMLHttpRequest();
		} catch (e) {
			try {
				g_xhrRequest = new ActiveXObject('Msxml2.XMLHTTP');
			} catch (e) {
				try {
					g_xhrRequest = new ActiveXObject('Microsoft.XMLHTTP');
				} catch (e) { g_xhrRequest = null; return; }
			}
		}
		
		try {
			g_xhrRequest.open("POST", varPostURL + "?" + sEvent, true);
			g_xhrRequest.send("");
		} catch(e){}
	}
}
