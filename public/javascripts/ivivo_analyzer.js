/*
01.07.2009 19:00

In script of Plugin loading exists global string variable objDocPlugin
If it undefined - Ivivo Plugin not exists in the page
If it = "" - Plugin is not initialized
If it contents something - it is ID of Plugin Object
*/
var bAJAXLoad = false;

var bIgnoreWholeSession = false; //raise if failed to retrieve url ID on event 7
var arrEvents = [];
arrEvents = new Array(0);
var arrMessages = [];
arrMessages = new Array(0);
var bDispatcherRunning  = false;

var objDocPlayer;
objDocPlayer = "";
var oPlugin;
oPlugin = null;
var varAnalyzerID;
var sIvivoPostURL = escape("http://www.ivivo.tv/Tools/StateWMP.asp");
//var sIvivoPostURL = escape("http://test.ivivo.tv/Tools/StateWMP.asp");
var cIViVoDelimiter = "&";

var wmp = null;

var varURLID = "";
var sCurrentPlayURL = "";
var sCurrentPlayList = "";
var sRecentPlayedURL = "";

var StateDummy = -1;
var EventDummy = -1;
var bMonitoring = false;
var lBuferCounterInItem = 0;
var bSentPlayListMoveEvent = false;
var bLoggoffProcedure = false;
var bPlaylistMode = true;

var MONITORING_PACKETS_INTERVAL = 5000; // the interval for checking lost packets (in milliseconds)
var oCheckingObject = null;
var g_bInitDone = false;

var g_xhrRequest = null; // ajax object - used to send and receive info to and from the server
var postTimeoutID = null;
var nPostTimeout = 25000;
var bPostDispatcherRunning = false;
var SESSION_MIN_DURATION = 3000; //we will collect message while the delay to check if leaving event was received 
var g_bSessionSuspended = true; // we will suspend the message for a while to check if it's real session
var hSessionDurationLimitID = null;
var bSessionStartOnItemOnly = true;

var lNextCell = 0; // the index of the cell in the current disruption session to which we want to save the info (0 or 1)
var oCheckingLostPackets; // // the lost packets monitoring object - used to stop the monitoring
var lCurrItemPacketsReceived; // num of packets received for the current item
var lCurrItemPacketsRecovered; // num of packets recovered for the current item
var lCurrItemBitRate; // bitrate of the current item
var lCurrItemTotalPlaySeconds = 0; // total play time of the current item. used for the packet size estimation
var lNumOfAverageBandwidthUpdates = 0;
var lCurrItemAverageBandwidth = 0; // average bandwidth of the current item
var bFirstCheck = true; // is this the first time we check num of lost packets for this item 
var bSaveSession = false; // do we need to save the disruption session when it finishes 
var bCheckingLostPackets = false; // are we currently monitoring the num of lost packets
var arrCurrDisruptionSession = [];// curr Disruption Session array
arrCurrDisruptionSession = new Array(2);
var arrRecordedDisruptionSessions = [];//recorded disruption sessions array
arrRecordedDisruptionSessions = new Array(0);
var oSuspendedEvent = null;
var nWaitForRealyNetWork = 0; //using this counter for filter out starting events in RelayNet mode
//var bSkipPlayListStop = false; //helper in RelayNet mode to block original playlist stop sending on replace to virtual playlist for RelayNet
//var bSkipPlayListStart = false; //helper in RelayNet mode to block original playlist start sending on replace to virtual playlist for RelayNet
var sStoppedItem = ""; //flag for already stopped item, transioning on new item still come with link for already stopped. filter flag

var nReconnect2Obj = -1;

// this function generates an ID for the player object
function GeneratePlayerID() 
{
	if (readCookie("PlayerID") != null) return readCookie("PlayerID");
	var d, s = "";
	d = Math.round(Math.random() * 100000000);
	s = d.toString();
	if (s.length > 8) {
		s = s.substring(0,8);
	} else {
		while (s.length < 8) {
			s = "0" + s;
		}
	}
  
	createCookie("PlayerID","WM"+s, 365);
	return "WM" + s;
}

function RelayNetMode()
{
	if ( null == oPlugin || undefined == oPlugin ) return false;
	return true;
}

var varPlayerID = GeneratePlayerID(); 

//var varPostURL = "http://127.0.0.1/cgi-bin/state.pl"; 
var varPostURL;
function getProxyURL(varAnalyzerID)
{
	switch (varAnalyzerID) 
	{
		case 8:
			varPostURL = "http://www.cast-tv.biz/play/StateOwnerWMP.asp";
			break;
		case 23:
			varPostURL = "http://www.cast-tv.biz/play/StateOwnerWMP.asp";
			break;
		case 27:
			varPostURL = "http://www.cast-tv.biz/play/StateOwnerWMP.asp";
			break;
		case 28:
			varPostURL = "http://www.cast-tv.biz/play/StateOwnerWMP.asp";
			break;
		case 29:
			varPostURL = "http://www.cast-tv.biz/play/StateOwnerWMP.asp";
			break;
		case 30:
			varPostURL = "http://www.cast-tv.biz/play/StateOwnerWMP.asp";
			break;
		case 31:
			bAJAXLoad = true;
			varPostURL = "/ivivo/analyzerproxy.php";
			break;
		case 32:
			bAJAXLoad = true;
			varPostURL = "/analyzerproxy.php";
			break;
		case 666999:
			varPostURL = "/analyzer/Test.Analyzer.Proxy.asp";
			break;
		default:
			varPostURL = "StateOwnerWMP.asp";
			break;
	}
return varPostURL;
}

var MIN_BUFFERING_DURATION_TO_RECORD = 1000;
var biCurrBufferingInfo; // the current buffering info
var arrBufferingsInfo = [];
arrBufferingsInfo = new Array(0); // the recorded bufferings array

var lItemsInPlaylistCounter = 0; // counter of played items
var dtCurrItemStartTime;

// event types
var evPlayState = 1;
var evOpenState = 2;
var evBuffering = 3;
var evChangeMedia = 4;

// event type string
var sEventType = [];
sEventType[0] = "dummy";
sEventType[1] = "playStateChange";
sEventType[2] = "openStateChange";
sEventType[3] = "buffering";
sEventType[4] = "Change Media";

// open states definitions
var oStateUndefined = 0;
var oStatePlaylistChanging = 1;
var oStatePlaylistLocating = 2;
var oStatePlaylistConnecting = 3;
var oStatePlaylistLoading = 4;
var oStatePlaylistOpening = 5;
var oStatePlaylistOpenNoMedia = 6;
var oStatePlaylistChanged = 7;
var oStateMediaChanging = 8;
var oStateMediaLocating = 9;
var oStateMediaConnecting = 10;
var oStateMediaLoading = 11;
var oStateMediaOpening = 12;
var oStateMediaOpen = 13;
var oStateBeginCodecAcquisition = 14;
var oStateEndCodecAcquisition = 15;
var oStateBeginLicenseAcquisition = 16;
var oStateEndLicenseAcquisition = 17;
var oStateBeginIndividualization = 18;
var oStateEndIndividualization = 19;
var oStateMediaWaiting = 20;
var oStateOpeningUnknownU = 21;

// open state strings	
var sOpenState = [];
sOpenState[0] = "Undefined";
sOpenState[1] = "PlaylistChanging";
sOpenState[2] = "PlaylistLocating";
sOpenState[3] = "PlaylistConnecting";
sOpenState[4] = "PlaylistLoading";
sOpenState[5] = "PlaylistOpening";
sOpenState[6] = "PlaylistOpenNoMedia";
sOpenState[7] = "PlaylistChanged";
sOpenState[8] = "MediaChanging";
sOpenState[9] = "MediaLocating";
sOpenState[10] = "MediaConnecting";
sOpenState[11] = "MediaLoading";
sOpenState[12] = "MediaOpening";
sOpenState[13] = "MediaOpen";
sOpenState[14] = "BeginCodecAcquisition";
sOpenState[15] = "EndCodecAcquisition";
sOpenState[16] = "BeginLicenseAcquisition";
sOpenState[17] = "EndLicenseAcquisition";
sOpenState[18] = "BeginIndividualization";
sOpenState[19] = "EndIndividualization";
sOpenState[20] = "MediaWaiting";
sOpenState[21] = "OpeningUnknownU";
	
// play sates definitions
var pStateUndefined = 0;
var pStateStopped = 1;
var pStatePaused = 2;
var pStatePlaying = 3;
var pStateScanForward = 4;
var pStateScanReverse = 5;
var pStateBuffering = 6;
var pStateWaiting = 7;
var pStateMediaEnded = 8;
var pStateTransitioning = 9;
var pStateReady = 10;
var pStateReconnecting = 11;

// play state strings
var sPlayState = [];
sPlayState[0] = "Undefined";
sPlayState[1] = "Stopped";
sPlayState[2] = "Paused";
sPlayState[3] = "Playing";
sPlayState[4] = "ScanForward";
sPlayState[5] = "ScanReverse";
sPlayState[6] = "Buffering";
sPlayState[7] = "Waiting";
sPlayState[8] = "MediaEnded";
sPlayState[9] = "Transitioning";
sPlayState[10] = "Ready";
sPlayState[11] = "Reconnecting";

	
// IViVo events
var arrEventsFlags = [];
var evIViVoPlaylistPlay = 7;
var evIViVoStopItem = 16;
var evIViVoMoveNextItemOnEnd = 22;
var evIViVoStartItem = 25;
var evIViVoMoveNextItemAnyReason = 26;
var evIViVoStartBuffering = 32;
var evIViVologoff = 33;
var evIViVoStartVideo = 34;
var evIViVoStartAudio = 35;
var evIViVoPlaylistStop = 36;
var evIViVoMonitoring = 51;

var FATAL = 50000;
var ERROR = 40000;
var WARN = 30000;
var INFO = 20000;
var DEBUG = 10000;
var TRACE = 5000;

function showlog(level, message)
{
	var sMsg = "";
	try
	{
		for(var i = 1; i < arguments.length; i++) {
			sMsg += arguments[i] + " ";
		}

		do {
			if ( level <= TRACE ) {log.trace(sMsg); break;}
			if ( level <= DEBUG ) {log.debug(sMsg); break;}
			if ( level <= INFO ) {log.info(sMsg); break;}
			if ( level <= WARN) {log.warn(sMsg); break;}
			if ( level <= ERROR ) {log.error(sMsg); break;}
			if ( level <= FATAL) {log.fatal(sMsg); break;}
		}
		while(false);
	}
	catch(err){}
}

// Add event into window.onunload
function addUnLoadEvent(func) {
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
	} catch(e) {
		printStackTrace();
	}
}


// this function is called when the page loads
function Init() 
{
	var fn = "Init";
	var bRet	= false;
  // init the media player object
    
	// if using Internet explorer - attach events dynamically. 
	// in firefox the events will be caught by the general event handlers 
		
	if ( null == wmp || undefined == wmp )
	{
		showlog(WARN, fn, "Init No connection to player");
		return bRet;
	}
	
	showlog(WARN, fn, ".URL", wmp.URL, "sCurrentPlayList", sCurrentPlayList);
	
	if (-1 != navigator.userAgent.indexOf("MSIE"))
	{
		if ( 0 == sCurrentPlayList.length || sCurrentPlayList != wmp.URL )
		{
			// registering for the media player events
			bRet = RegisterEvents();
			SetEventStatus(evIViVoPlaylistPlay, false);
			nReconnect2Obj = -1;
		}
		else
		{
			showlog(DEBUG, fn, "skipped event registration", sCurrentPlayList, wmp.URL);
		}
		
/*
		//care autostart miss event ticket #151
		try {
			if ( true == wmp.settings.autoStart && 0 < wmp.URL.length )
			{
				showlog(DEBUG, fn, "start playlist event manual for ", wmp.URL);
				if ( undefined != DispatchTable[evOpenState * 100 + oStatePlaylistChanged] )
				{
					sCurrentPlayList = wmp.URL;
					var objEventResult = 	DispatchTable[evOpenState * 100 + oStatePlaylistChanged](wmp.URL);
					if ( objEventResult != null && objEventResult.IsFilled() ) 
					{
						post(objEventResult.GetMessage(), objEventResult.GetData(), objEventResult.GetHook());
					}
				}
				else
				{
					showlog(WARN, fn, "Failed to send 7 event for playlist on autostart");
				}
			
				if ( undefined != DispatchTable[evPlayState * 100 + pStatePlaying] )
				{
					var objEventResult = 	DispatchTable[evPlayState * 100 + pStatePlaying](wmp.URL);
					if ( objEventResult != null && objEventResult.IsFilled() ) 
					{
						post(objEventResult.GetMessage(), objEventResult.GetData(), objEventResult.GetHook());
					}
				}
				else
				{
					showlog(WARN, fn, "Failed to send start event for playlist on autostart");
				}
			}
			else
			{
				showlog(DEBUG, fn, "start playlist event manual SKIPPED for ", wmp.settings.autoStart, wmp.URL);
			}
		}
		catch (err)
		{
			showlog(WARN, err);
			printStackTrace();
		}
*/
	}
	else
	{
		if ( true == g_bInitDone ) return;
		bRet = true;
		showlog(DEBUG, fn, "FF skipped manual events on autostart for", wmp.URL);
	}		

	if ( true == bRet && undefined != wmp.versionInfo )
	{
		g_bInitDone = true;
	}
	
	showlog(DEBUG, fn, "playerID is", varPlayerID, "Object", (wmp != null ? "is found" : "isn't found"), "version", (wmp != null ? wmp.versionInfo : "NaN"));

	addUnLoadEvent(analyzer_Logoff);
	
	bRet = true;
	return bRet;
}

function IfAJAXLoading()
{
	var fn = "IfAJAXLoading";
	var bRet = false;
	
	try
	{
		bRet = bAJAXLoad;
		showlog(fn, "AJAX object loading");
	}
	catch(err){}
	
	return bRet;
}

function analyzer_CheckObject() {
	var fn = "analyzer_CheckObject()";
  var MONITORING_OBJECT_INTERVAL = 50;
	findPlayerID();

	if (objDocPlayer=="")
	{
		oCheckingObject = setTimeout(fn, MONITORING_OBJECT_INTERVAL);
		showlog(INFO, fn, "keep monitoring on objDocPlayer is void");
		return;
	} 
	else 
	{
		//if ( null == wmp)
		wmp = analyzer_getAnalyzerObject(objDocPlayer);

		if ( false == Init() || (true == IfAJAXLoading() && 0 <= nReconnect2Obj) )
		{
			nReconnect2Obj = nReconnect2Obj + 1;
			var nInterval = MONITORING_OBJECT_INTERVAL;
			if ( nReconnect2Obj > 20 ) nInterval = nInterval * 20;
			
			oCheckingObject = setTimeout(fn, nInterval);
			showlog(INFO, fn, "keep monitoring on wmp is null or nReconnect2Obj", nReconnect2Obj, nInterval);
			return;
		}
	}
	
	clearTimeout(oCheckingObject);
}

//	Checking object
if (-1 == navigator.userAgent.indexOf("Firefox"))
{
	analyzer_CheckObject();
}

function analyzer_getAnalyzerObject(objID)
{
	var fn = "analyzer_getAnalyzerObject";
	var obj = null;
	var FoundCase = "";
	
	try
	{
		showlog(WARN, fn, "objID->", objID);
		do
		{
			FoundCase = "window.document[objID]";
			if (window.document[objID]) obj = window.document[objID];

			if  ( null != obj && undefined != obj.name ) break;

			FoundCase = "document.embeds[objID]";			
			if (!(navigator.userAgent.indexOf("MSIE") != -1) && document.embeds && document.embeds[objID]) obj = document.embeds[objID]; 

			if  ( null != obj && undefined != obj.name ) break;

			FoundCase = "document.getElementById(objID)";
			if (navigator.userAgent.indexOf("MSIE") != -1) obj = document.getElementById(objID); // If IE

			if  ( null != obj && undefined != obj.name ) break;

			FoundCase = "PASSED ALL";
			
		}while(false);
	}
	catch(err)
	{
		showlog(WARN, fn, "objID->", objID, err);
		printStackTrace();
	}

	showlog(DEBUG, fn, (null!=obj?("FOUND "):"NOT FOUND"), "in case", FoundCase);
	return obj;
}

function analyzer_Logoff()
{
	var fn = "analyzer_Logoff";
	bLoggoffProcedure = true;
	
	if ( true == bIgnoreWholeSession ) return null;
	if ( true == g_bSessionSuspended ) return null;
  	
	var vEvent = evIViVologoff;
	var bSendStatus = true;
		
	try
	{
		showlog(DEBUG, "Analyzer logoff. State", sPlayState[wmp.playState]);

		switch (wmp.playState)
		{
			case pStatePlaying:
			case pStateBuffering:
				bSendStatus = true;
				break;
			case pStateStopped:
			case pStateReady:
			case pStateMediaEnded:
				bSendStatus = false;
				break;
			default:
				break;
		}

    var sURL = sRecentPlayedURL;
    if ( 0 == sURL.length ) sURL = sCurrentPlayList;
		if ( 0 == sURL.length ) sURL = sCurrentPlayURL;

		showlog(DEBUG, "Analyzer logoff. URL", sURL, "bSendStatus", bSendStatus);
		var sEvent = fnItemOnEnd(vEvent, sURL, bSendStatus);
		
		if ( sEvent != null ) 
		{
			post(sEvent, null, null, true);
		}
	}
	catch (err)
	{
		showlog(ERROR, fn, err.description, err);
		printStackTrace();
	}
	
	//Enable next if you wish to wait to send all messages in queue
	//while ( null != arrMessages && 0 < arrMessages.length ) {};
}
function GetStateName(type, state)
{
	var fn = "GetStateName";
	var name = "";
	
	switch(type)
	{
		case evPlayState:
			name = sPlayState[state];
			break;
		case evOpenState:
			name = sOpenState[state];
			break;
		case evBuffering:
			name = sPlayState[6];
			state = (state == true ? 1 : 0);
			break;
		case evChangeMedia:
			state = 0;
			break;
		default:
			break;
	}
	
	return name;
}
function EventDispatcherThread()
{
	var oEvent;
	bDispatcherRunning = true;

	while ( false == bIgnoreWholeSession && undefined != (oEvent = GetEvent()))
	{
		event_dispatcher(oEvent.GetType(), oEvent.GetState(), oEvent.GetURL());
	}

	//showlog(DEBUG, fn, "EventDispatcherThread complete");
	bDispatcherRunning = false;
}

function GetEvent(Type, State){
	return arrEvents.pop();
}

function SetEvent(Type, State){
	var fn = "SetEvent";
	showlog(DEBUG, fn, sEventType[Type].toUpperCase(), "::", GetStateName(Type, State).toUpperCase());
	
	nReconnect2Obj = -1;
	clearTimeout(oCheckingObject);
	
	if ( true == bIgnoreWholeSession ) return null;
	
	try
	{
		if ( wmp == null || wmp == undefined) 
		{
			analyzer_CheckObject();
			
			if ( null == wmp )
			 showlog(FATAL, fn, "Exist event but no the source");
		}

	}
	catch(err)
	{
		showlog(ERROR, fn, err.description, err);
	}
	
	var sURL = "";
	try
	{
		sURL = wmp.currentMedia.sourceURL;
	}
	catch(err)
	{
		showlog(WARN, fn, "Exception in retrieve URL", err.description, err);
		try 
    {	
      sURL = wmp.URL;
      showlog(DEBUG, fn, "Trying player.URL", sURL);
    }
		catch(err)
		{
		  showlog(ERROR, fn, "Exception in retrieve URL", err.description, err);
    }
	}
	
	if ( undefined == sURL)
	{
		showlog(WARN, fn, "Skip no URL event");
		return;
	}
	
	if ( evOpenState == Type )
	{
		do
		{
			var sTmp = wmp.URL;
			
			showlog(DEBUG, fn, "evOpenState for", sTmp, sCurrentPlayList);
			
			//differ URL
			if ( null != sCurrentPlayList && undefined != sCurrentPlayList)
			{
				if ( sCurrentPlayList == sTmp )
				{
					showlog(DEBUG, fn, "known playlist", sTmp); 
					break;
				}
			}
			
			switch (State)
			{
				case oStateMediaOpen:
				case oStatePlaylistChanging:
				case oStatePlaylistLocating:
				case oStatePlaylistConnecting:
				case oStatePlaylistLoading:
				case oStatePlaylistOpening:
				case oStatePlaylistChanged:
				{
					if ( true == bIgnoreWholeSession )
					{
						showlog(DEBUG, fn, "Ignore the session", sCurrentPlayURL);
					}
					//if ( undefined != sTmp && 0 < sTmp.length )
					{				
						if ( false == GetEventStatus(evIViVoStopItem) && undefined != sCurrentPlayURL && 0 < sCurrentPlayURL.length )
						{
							showlog(DEBUG, fn, "Simulate pStateStopped", sCurrentPlayURL);
							event_dispatcher(evPlayState, pStateStopped, sCurrentPlayURL);
						}
	
						if ( false == GetEventStatus(evIViVoPlaylistStop) && undefined != sCurrentPlayList && 0 < sCurrentPlayList.length )
						{
							showlog(DEBUG, fn, "Simulate pStateReady ->", sCurrentPlayList, "status", GetEventStatus(evIViVoPlaylistStop));
							event_dispatcher(evPlayState, pStateReady, sCurrentPlayList);
						}
						
						showlog(WARN, fn, "Playlist .URL changed current", sCurrentPlayList, "new", sTmp);
						BlockStartRestore();
						ClearEventsSet(true);
						ClearSessionSuspend();
						g_bSessionSuspended = true;
						bIgnoreWholeSession = false;
						//sCurrentPlayList = sTmp;
						varURLID = "";
					}
					//else
					//{
						//showlog(DEBUG, fn, "No wmp.URL");
					//}
					break;
				}
				default: break;
			}
		}while(false);
	}	

	var oEvent = new Event(Type, State, sURL);
	arrEvents.unshift(oEvent);

	showlog(DEBUG, fn, "Event's array size is", arrEvents.length, " event thread", bDispatcherRunning, "sURL", sURL);
	
	if ( false == bDispatcherRunning )
	{
		EventDispatcherThread();
	}
}

function Event(Type, State, URL) {
	this.nType = Type;
	this.nState = State;
	this.sURL = URL;

	this.GetType = function ()
	{return this.nType;}
	this.GetState = function ()
	{return this.nState;}
	this.GetURL = function ()
	{return this.sURL;}
}

function EventResult(sMsg, sData, fnHook){ //event action return type
	this.sMsg = sMsg;
	this.sData = sData;
	this.fnHook = fnHook;
	
	this.GetMessage = function ()
	{ return this.sMsg; };
	this.GetData = function ()
	{ return this.sData; };
	this.GetHook = function ()
	{ return this.fnHook; };
		
	this.IsFilled = function ()
	{
		if (this.sMsg.length > 0 || this.fnHook )
			return true;
		else
			return false;
	};
}

// this function attaches the event handlers to the matching media player events 
function RegisterEvents() 
{
	var fn = "RegisterEvents";
	var bRet = false;
	
	showlog(DEBUG, fn);
	
	try
	{
		wmp.attachEvent("playStateChange", OnPlayStateChange);
		wmp.attachEvent("OpenStateChange", OnOpenStateChange);
		wmp.attachEvent("Buffering", OnBuffering);
		bRet = true;
	}catch(err)
	{
		showlog(WARN, "RegisterEvents" + err);
		printStackTrace();
	}
	
	return bRet;
}

function OnPlayStateChange(NewState) {
	//event_dispatcher(evPlayState, NewState);
	SetEvent(evPlayState, NewState);
}
function OnOpenStateChange(NewState) {
	//event_dispatcher(evOpenState, NewState);
	SetEvent(evOpenState, NewState);
}
function OnBuffering(start) {
	//event_dispatcher(evBuffering, start);
	SetEvent(evBuffering, start);
}

function OnDSPlayStateChangeEvt(NewState) {
  //event_dispatcher(evPlayState, NewState);
  analyzer_CheckObject();
  SetEvent(evPlayState, NewState);
}
function OnDSOpenStateChangeEvt(NewState) {
	//event_dispatcher(evOpenState, NewState);
	analyzer_CheckObject();
	SetEvent(evOpenState, NewState);
}
function OnDSBufferingEvt(start) {
    //event_dispatcher(evBuffering, start);
  analyzer_CheckObject();
  SetEvent(evBuffering, start);
}

// event translator
var DispatchTable = [];

DispatchTable[evOpenState * 100 + oStatePlaylistChanging] 		= fnPlaylistStart;
DispatchTable[evOpenState * 100 + oStatePlaylistChanged] 			= fnPlaylistStart;
DispatchTable[evPlayState * 100 + pStateReady] 								= fnPlaylistStop;

DispatchTable[evOpenState * 100 + oStateMediaOpening] 				= fnItemStart;
DispatchTable[evOpenState * 100 + oStateMediaChanging] 				= fnItemStart;
DispatchTable[evOpenState * 100 + oStateMediaOpen]						= fnItemStart;
DispatchTable[evPlayState * 100 + pStatePlaying]							= fnItemStart;
DispatchTable[evPlayState * 100 + pStateTransitioning]				= fnItemStart;

DispatchTable[evPlayState * 100 + pStateStopped]							= fnItemStop;

DispatchTable[evPlayState * 100 + pStateMediaEnded] 					= fnItemMoveNext;

DispatchTable[evBuffering * 100 + 0]  												= undefined;
DispatchTable[evBuffering * 100 + 1]  												= undefined;
//DispatchTable[evChangeMedia * 100]													= fnChangeMedia;

function UpdateBufferingStatus() {
   showlog(DEBUG, "Buffering progress: " + wmp.network.bufferingProgress);
}

// Event message helpers
function BuildCommonEvent(eventNum, sourceURL, sMoreData) {
	
	var sEvent = "";
	
	if (sourceURL == null || (sourceURL != null && sourceURL.length == 0) )
	{
		showlog(ERROR, "BuildCommonEvent. SourceURL is void for event ", eventNum);
		return null;
	}
	
	sEvent += strGetPlayerID();
	sEvent += strGetAnalyzerID();
	sEvent += strGetEventID(eventNum);
	sEvent += strGetEventTime();
	
	//in some case we need to add more infor to report message
	if ( sMoreData != null && sMoreData.length > 0) sEvent += sMoreData + cIViVoDelimiter;
	
	sEvent += strGetURLID();
	sEvent += strGetURL(sourceURL);

	showlog(DEBUG, "BuildCommonEvent. On event", eventNum, "for", sourceURL);
		
	return sEvent;
}

function BuildEventEx(eventNum, sourceURL, sMoreData) {
	var sEvent = "";
	sEvent += strGetPlayerID();
	sEvent += strGetAnalyzerID();
	sEvent += strGetEventID(eventNum);

	//in some case we need to add more infor to report message
	if ( sMoreData != null && sMoreData.length > 0) sEvent += sMoreData + cIViVoDelimiter;
	
	sEvent += strGetEventTime();
	sEvent += strGetURLID();
	sEvent += strGetURL(sourceURL);
	
	return sEvent;
}

function strGetPlayerID(pDelimeter) {
	var str = "playerID=" + varPlayerID;
	if ( pDelimeter == null ) str += cIViVoDelimiter;
	return str;
}
function strGetAnalyzerID(pDelimeter) {
	var str = "uid=" + varAnalyzerID;
	if ( pDelimeter == null ) str += cIViVoDelimiter;
	return str;
}
function strGetEventID(eventNum, pDelimeter) {
	var str = ""; 
	if ( eventNum > -1 )
	{
		str = "event=" + itoa(eventNum);
		if ( pDelimeter == null ) str += cIViVoDelimiter;
	}
	return str;
}
function strGetEventTime(pDelimeter) {
	var str = ""; str = "eventTime=" + GetUtcString();
	if ( pDelimeter == null ) str += cIViVoDelimiter;
	return str;
}
function strGetURLID(pDelimeter)  {
	var str = "";
	if ( null != varURLID && 0 < varURLID.length )
	{
		var str = "urlsid=" + varURLID;
		if ( pDelimeter == null ) str += cIViVoDelimiter;
	}
	return str;
}
function strGetURL(URL, pDelimeter)  {
	var fn = "strGetURL";
	
	//patch for ivivo plugin
	//if url contain 127.0.0.1 we will replace with url from activeX
	var sUrl = URL;
	try 
	{
		do 
		{
			if ( null == sUrl || undefined == sUrl ) break;
			if ( 0 == sUrl.length ) break;

			if ( false == RelayNetMode() )  break;

      var sPluginURL = oPlugin.URL;
			if ( null ==	sUrl.match("127.0.0.1")  && null == sPluginURL.match(sUrl) ) 
			{
				showlog(WARN, fn, "RelayNet mode but no replace", sUrl, "to", oPlugin.URL, "oPlugin.StreamURL ->", sPluginURL); 
				break;
			}
			
			if ( undefined == sPluginURL || 0 == sPluginURL.length )
			{
			  showlog(WARN, fn, "RelayNet mode but no replace", sUrl, "to", oPlugin.URL, " void oPlugin.StreamURL ->", sPluginURL); 
				break;
      }
      
			showlog(DEBUG, fn, "replace", sUrl, "to", sPluginURL);
			sUrl = sPluginURL;
		}
		while(false);
	}
	catch (err)
	{
		showlog(ERROR, fn, err.description, err);
		printStackTrace();
	}
	
	var str = "url=" + escape(sUrl);
	//URL is last param
	if ( pDelimeter != null ) str += cIViVoDelimiter;
	return str;
}


// Dispatcher blockers
function ItemStartBlock() {
	showlog(DEBUG,"ItemStartBlock");
	DispatchTable[evOpenState * 100 + oStateMediaOpening] 				= undefined;
	DispatchTable[evOpenState * 100 + oStateMediaOpen]						= undefined;
	DispatchTable[evPlayState * 100 + pStatePlaying]							= fnPatchForStartShowMedia;
	DispatchTable[evPlayState * 100 + pStateTransitioning]				= undefined;
	DispatchTable[evOpenState * 100 + oStatePlaylistChanging]			= undefined;
	DispatchTable[evOpenState * 100 + oStateMediaChanging] 				= fnChangeMedia;
	DispatchTable[evBuffering * 100 + 0]  												= fnBufferingContinous;
	DispatchTable[evBuffering * 100 + 1]  												= fnBufferingStart;
}
function BlockStartRestore() {
	showlog(DEBUG,"BlockStartRestore");
	DispatchTable[evOpenState * 100 + oStatePlaylistChanging]			= fnPlaylistStart;
	DispatchTable[evOpenState * 100 + oStatePlaylistChanged] 			= fnPlaylistStart;
	
	DispatchTable[evBuffering * 100 + 0]  												= undefined;
	DispatchTable[evBuffering * 100 + 1]  												= undefined;

	DispatchTable[evOpenState * 100 + oStateMediaOpening] 				= fnItemStart;
	DispatchTable[evOpenState * 100 + oStateMediaChanging] 				= fnItemStart;
	DispatchTable[evOpenState * 100 + oStateMediaOpen]						= fnItemStart;
	DispatchTable[evPlayState * 100 + pStatePlaying]							= fnItemStart;
	DispatchTable[evPlayState * 100 + pStateTransitioning]				= fnItemStart;
}

function fnBlockTransitioning(sourceURL)
{
	DispatchTable[evPlayState * 100 + pStateTransitioning] = undefined;
	showlog(WARN, "fnBlockTransitioning for ", sourceURL);
}

// Events action's functions
function fnPlaylistStart(sourceURL) {

	var fn = "fnPlaylistStart";
	
	if ( 0 < sCurrentPlayList.length && sourceURL.Match("mms://") )
	{
		showlog(DEBUG, fn, "Filter out stream. sCurrentPlayList", sCurrentPlayList, "sourceURL", sourceURL);
		return null;
	}
	
	if ( true == RelayNetMode() )
	{
    var sStreamURL = oPlugin.StreamURL;
    if ( 0 < sStreamURL.length && sStreamURL.match(sourceURL) ) 
    {
    	showlog(DEBUG, fn, "RelayNet mode. Start RelayNet playlist", sourceURL, "StreamURL", sStreamURL);
    	SetEventStatus(evIViVoPlaylistStop, true);
    	wmp.controls.play();
    	return null;
    }
    else
    {
      showlog(DEBUG, fn, "RelayNet mode. Not matching URL", sourceURL, "StreamURL", sStreamURL);
    }
  }
  else
  {
    showlog(DEBUG, fn, "Non RelayNet mode.", sourceURL);
  }

	if ( true == bSessionStartOnItemOnly )
	{
		sCurrentPlayList = sourceURL;
		showlog(DEBUG, fn, "bSessionStartOnItemOnly", bSessionStartOnItemOnly, sCurrentPlayList);
		return null;
	} 
	/*
	if ( null != sourceURL.match("mms://") && 0 < varURLID.length )
	{
			showlog(DEBUG, fn, "Skip playlist start for direct link to stream", sourceURL, "urlID", varURLID);
			return null;
	}
	*/
	if ( null != sourceURL )
	{
		if ( (0 < varURLID.length || true == g_bSessionSuspended) && sCurrentPlayList == sourceURL )
		{
			showlog(WARN, fn, "Exist session ID", varURLID, "for", sCurrentPlayList);
			return null;
		}
		else
		{
			showlog(WARN, fn, "Clear session ID for new playlist ", sourceURL);
			varURLID = "";
			SetEventStatus(evIViVoPlaylistPlay, false);
			g_bSessionSuspended = true;
			bIgnoreWholeSession = false;
		}
	}
	else 
	{
		showlog(WARN, fn, "Not exist sourceURL");
	}

	if ( true == GetEventStatus(evIViVoPlaylistPlay) && 0 < varURLID.length )
	{
		showlog(DEBUG, fn, "Skip playlist start", sourceURL, "urlID", varURLID);
		SetEventStatus(evIViVoPlaylistPlay, false);
		return null;
	}
		
	var sEvent = ""; sEvent = BuildCommonEvent(evIViVoPlaylistPlay, sourceURL);

	DispatchTable[evOpenState * 100 + oStatePlaylistChanged] = undefined;

	ClearEventsSet(true);
  SetEventStatus(evIViVoPlaylistPlay, true);
	bSentPlayListMoveEvent = false;
	sCurrentPlayList = sourceURL;

	try
	{
		if ( true == RelayNetMode() )
		{
			showlog(DEBUG, fn, "RelayNet mode set playlist to control to", sCurrentPlayList)
			oPlugin.PlaylistURL = sCurrentPlayList;
		}
	}
	catch(err)
	{
		showlog(ERROR, err.description);
		printStackTrace();		
	}
	
	bPlaylistMode = true;
	//TODO: we should check the item via player objects #210
	if ( null != sCurrentPlayList.match("mms://") )
	{
		//sCurrentPlayList = "";
		bPlaylistMode = false;
	}
	
	DispatchTable[evPlayState * 100 + pStateTransitioning] = fnItemStart;
	
	var res = new EventResult(sEvent, null, SetURLSessionID);
	showlog(WARN, fn, (bPlaylistMode ? " PLAYLIST " : " DIRECT LINK "), res.GetMessage(), (res.GetHook() != null ? "defined" : "null"));
	return res;
}
function fnPlaylistStop(sourceURL) {
	var fn = "fnPlaylistStop";

	showlog(DEBUG, fn, "nWaitForRealyNetWork is ", nWaitForRealyNetWork, "bSkipPlayListStop", GetEventStatus(evIViVoPlaylistStop));
	if ( 1 == nWaitForRealyNetWork || true == GetEventStatus(evIViVoPlaylistStop))
	{
			showlog(INFO, fn, "filtered out RelayNet mode")
			nWaitForRealyNetWork = 0;
			SetEventStatus(evIViVoPlaylistStop, false);
			SetEventStatus(evIViVoPlaylistPlay, true);
			return null;
	}

	lItemsInPlaylistCounter = 0;
	
	BlockStartRestore();
	
	//block items report between playlist changes
	DispatchTable[evPlayState * 100 + pStateTransitioning] = undefined;
	DispatchTable[evOpenState * 100 + oStatePlaylistChanged] = fnPlaylistStart;
	
	if ( null != sCurrentPlayList || 0 < sCurrentPlayList.length )
	{
		var sEvent = ""; sEvent = BuildCommonEvent(evIViVoPlaylistStop, sCurrentPlayList);
		var res = new EventResult(sEvent, null, null);
		
		sRecentPlayedURL = sCurrentPlayList;
		sCurrentPlayList = "";
		SetEventStatus(evIViVoPlaylistPlay, false);
		SetEventStatus(evIViVoPlaylistStop, true);
		sStoppedItem = "";
		
		showlog(DEBUG, fn, "Handler fnPlaylistStart is restored.");
	}
	else
	{
		showlog(WARN, fn, "sCurrentPlayList is void. Skipped.");
	}

	return res;
}
function fnItemStart(sourceURL) {
	var fn = "fnItemStart";
	var sProtocol = "";

	if ( 0 == sourceURL.length )
	{
		showlog(WARN, fn, "source URL is void. Take out");
		return null;
	}

	try
	{
		//filter out RelayNet stub playlist
		if ( true == RelayNetMode() )
		{
			var sStreamURL = oPlugin.StreamURL;
			if ( sStreamURL.match(sourceURL) )
			{
				showlog(INFO, fn, "RelayNet mode filter out playlist");
				SetEventStatus(evIViVoPlaylistStop, true);
				return null;
			}
		}
	}
  catch(err)
	{
		showlog(WARN, fn, "RelayNet mode.", err.description, err);
		printStackTrace();		
	}
	
	//event is come on play list, not item
	if ( sCurrentPlayList != sourceURL ) 
	{
		var objEventResult = fnItemMoveNext(sCurrentPlayList);
		
		if ( objEventResult != null && objEventResult.IsFilled() ) 
		{
			post(objEventResult.GetMessage(), objEventResult.GetData(), objEventResult.GetHook());
		}

			//RelayNet mode support only live streams
			try
			{
			  	if ( null != sourceURL.match("mms") && null == sourceURL.match("127.0.0.1")) 
				{
					showlog(INFO, fn, "trying to pass the stream to RelayNet mode", sourceURL);
					
					//if exist RelayNet plugin we will save the event and not send now
					if ( true == RelayNetMode() )
					{
						if ( 0 == nWaitForRealyNetWork )
						{
							var sEvent = ""; sEvent = BuildCommonEvent(evIViVoStartItem, sourceURL);
							oSuspendedEvent  = new EventResult(sEvent, null, null);
							nWaitForRealyNetWork++;
							showlog(INFO, fn, "[", sourceURL, "] filtered out RelayNet mode. Suspended event is ", oSuspendedEvent.GetMessage());

							ItemStartBlock();
							
							return null;
						}
						else
						{
							showlog(INFO, fn, "Already monitoring in RelayNet mode");
						}
					}
				}
				else
				{
					showlog(WARN, fn, "Skipped item in RelayNet  mode. Not mms or localhost", sourceURL);
				}
			}
			catch(err)
			{
				showlog(WARN, fn, "RelayNet mode:", err);
				printStackTrace();				
				oSuspendedEvent = null;
			}
	
		
		lItemsInPlaylistCounter = lItemsInPlaylistCounter + 1;
		dtCurrItemStartTime = new Date();
		sCurrentPlayURL = sourceURL;
		SetEventStatus(evIViVoStartBuffering, false);
		SetEventStatus(evIViVoStartAudio, false);
		SetEventStatus(evIViVoStartVideo, false);

		ResetItemCounter();
		
		ItemStartBlock();

		LostPacketsStartChecking();

		try 
		{
			if ( bMonitoring ) 
				StartMonitoringItemInfo();
		}
		catch (err)
		{
			showlog(ERROR, err.description, err);
			printStackTrace();			
		}
	}
	else
	{
		showlog(WARN, fn, "It's second time playlist->", sCurrentPlayList, " srcURL->", sourceURL, " event status->", GetEventStatus(evIViVoStartItem));
		
		//already sent
		if ( true == GetEventStatus(evIViVoStartItem) ) 
		{
			ItemStartBlock();
			return null;
		}

		SetEventStatus(evIViVoStartItem, true)
	}


	var sEvent = "";
  
  if ( false == GetEventStatus(evIViVoPlaylistPlay) && (null == varURLID || 0 == varURLID.length) )
  {
    showlog(WARN, fn, "No session ID. Sending 7 request", GetEventStatus(evIViVoPlaylistPlay), "bSessionStartOnItemOnly", bSessionStartOnItemOnly, "sCurrentPlayList", sCurrentPlayList);
    
    if ( null == sCurrentPlayList || 0 == sCurrentPlayList.length )
    {
			sCurrentPlayList = sourceURL; 
		}
		
    sEvent = BuildCommonEvent(evIViVoPlaylistPlay, sCurrentPlayList);
    if ( null != sEvent && 0 < sEvent.length )
    {
    	g_bSessionSuspended = true;
			bIgnoreWholeSession = false;
      showlog(DEBUG, fn, sProtocol, sEvent);
      try {
        post(sEvent, null, SetURLSessionID);
        SetEventStatus(evIViVoPlaylistPlay, true);
      }
      catch(err)
      { 
        showlog(WARN, fn, err.description, err);
      }
    }
    
    ItemStartBlock();
    if ( true == RelayNetMode ) 
		{
			showlog(DEBUG, fn, "RelayNet mode set plugin playlist to", sourceURL);
			oPlugin.PlaylistURL = sourceURL;
		}
  }
  else
  {
    showlog(DEBUG, fn, "Play list start is already sent");
  }
  
  sCurrentPlayURL = sourceURL;
	sEvent = BuildCommonEvent(evIViVoStartItem, sourceURL);
	
	var res = new EventResult(sEvent, null, null);
	showlog(WARN, fn, sProtocol, res.GetMessage(), (res.GetHook() != null ? "defined" : "null"));
	return res;
}
function fnItemStop(sourceURL) {

	if ( 1 == nWaitForRealyNetWork )
	{
			showlog(INFO, "fnItemStop filtered out RelayNet mode ref=", nWaitForRealyNetWork)
			nWaitForRealyNetWork = 0;
			SetEventStatus(evIViVoPlaylistStop, true);
			return null;
	}
	
	sStoppedItem = sourceURL;
	var sEvent = ""; sEvent = fnItemOnEnd(evIViVoStopItem, sourceURL, true);
	SetEventStatus(evIViVoStopItem, true);
	
	var res = new EventResult(sEvent, null, null);
	showlog(WARN, "fnItemStop", res.GetMessage(), (res.GetHook() != null ? "defined" : "null"));
	return res;
}
function fnItemMoveNext(sourceURL) {

	if ( 1 == nWaitForRealyNetWork )
	{
			showlog(INFO, "fnItemMoveNext cancel RelayNet mode for ", sourceURL)
			nWaitForRealyNetWork = 0;
	}
	
	//recorder recent bufering, but not for playlist
	if (sCurrentPlayList != sourceURL)
		fnBufferingContinous();
	else
	{
		showlog(DEBUG, "fnItemMoveNext for playlist", bSentPlayListMoveEvent);
		if ( true == bSentPlayListMoveEvent ) 
		{
			return;
		}

		//FF in autostart is miss the start play event
		var objEventResult = 	fnItemStart(sourceURL);
		if ( objEventResult != null && objEventResult.IsFilled() ) 
		{
			post(objEventResult.GetMessage(), objEventResult.GetData(), objEventResult.GetHook());
		}
		
		bSentPlayListMoveEvent = true;
	}

	var sEvent = ""; sEvent = fnItemOnEnd(evIViVoMoveNextItemAnyReason, sourceURL, true);

	var res = new EventResult(sEvent, null, null);
	showlog(WARN, "fnItemMoveNext", res.GetMessage(), (res.GetHook() != null ? "defined" : "null"));
	return res;
}

function fnBufferingStart(sourceURL) {
	var fn = "fnBufferingStart";
	
	showlog(WARN, fn, "bSentFirstBuffering", GetEventStatus(evIViVoStartBuffering));
	var dtCurrTime = new Date();
	biCurrBufferingInfo = new BufferingInfo(dtCurrTime, -1);
	
	var res = null;
	var nBw = -1;

	if ( null != oSuspendedEvent )
	{
		showlog(INFO, fn, "filtered out RelayNet mode");
		try
		{
			//I should check why arrived here on when RelayNet started to work
			if ( true == RelayNetMode() && null == sourceURL.match("127.0.0.1"))
			{
				oPlugin.URL = sourceURL;
				showlog(INFO, fn, "RelayNet mode set plugin URL to", sourceURL);
				oSuspendedEvent = null;
				
				if ( 0 < oPlugin.StreamURL.length )
				{
					showlog(INFO, fn, "RelayNet mode replaced current player URL to", oPlugin.StreamURL);
					wmp.URL = oPlugin.StreamURL;
				}
				else
				{
					wmp.controls.stop();					
				}
				return null;
			}
			else
			{
				showlog(WARN, fn, "Exist suspend event but no connection to RelayNet plugin or localhost", sourceURL);
			}
		}
		catch(err)
		{
			showlog(WARN, fn, "failed in RelayNet mode", err.description, err);
			printStackTrace();			
		}
	}
	
	if ( false == GetEventStatus(evIViVoStartBuffering) )
	{
		try
		{
			nBw = wmp.currentMedia.getItemInfo("Bitrate");
			showlog(INFO, fn, "BitRate", nBw);
		}
		catch (e)
		{
			showlog(ERROR, fn, "On get Player.network.bandWidth", e);
			printStackTrace();
		}
		
		var sEvent = ""; sEvent = BuildCommonEvent(evIViVoStartBuffering, sourceURL);
		res = new EventResult(sEvent, nBw, null);
		
		SetEventStatus(evIViVoStartBuffering, true);
		
		showlog(WARN, fn, res.GetMessage(), (res.GetHook() != null ? "defined" : "null"));
	}
	else
	{
		showlog(WARN, fn, "skipped. Already sent");
	}

	return res;
}
function fnBufferingContinous(bCatchLastBuffInfo) {
	var fn = "fnBufferingContinous";
	showlog(WARN, fn, "Count is ", wmp.network.bufferingCount, "bCatchLastBuffInfo is", bCatchLastBuffInfo);

	//if was random jmp from item, checki if we need to catch the recent buffer info
	if ( null  != bCatchLastBuffInfo && true == bCatchLastBuffInfo )
	{
		fnDumpBufferRecentInfo();
		return null;
	}
	
	SendStartShowMedia();

	try
	{
		var nBufCount = wmp.network.bufferingCount;
		//skip first buffering
		if ( 2 > nBufCount  && undefined != biCurrBufferingInfo  )
		{
			showlog(DEBUG, fn, "Skipped first buffering event. Count is ", wmp.network.bufferingCount);
			biCurrBufferingInfo.SetIsRecorded(true);
		}
	
		//count 0 and exist buffer info is on end of item playing
		if ( nBufCount > 1 || (0 == nBufCount && biCurrBufferingInfo != undefined) )
		{
			fnDumpBufferRecentInfo();
		}
	}catch(err)
	{
		showlog(ERROR, fn, err.description, err);
	}
	
	return null;
}

function fnDumpBufferRecentInfo()
{
	var fn = "fnDumpBufferRecentInfo";
	try
		{
			if ( undefined != biCurrBufferingInfo && false == biCurrBufferingInfo.IsRecorded() )
			{
				var dtCurrTime = new Date();
				biCurrBufferingInfo.SetDuration(dtCurrTime.getTime() - biCurrBufferingInfo.GetStartTime().getTime());

				var nDuration = biCurrBufferingInfo.GetDuration();
        // if buffering duration is longer then value save the info in a new cell in the array     
        if (nDuration >= MIN_BUFFERING_DURATION_TO_RECORD)
        { 
					lBuferCounterInItem = lBuferCounterInItem + 1;
    			arrBufferingsInfo[arrBufferingsInfo.length] = biCurrBufferingInfo;
					biCurrBufferingInfo.SetIsRecorded(true);
					showlog(WARN, fn, "Dumping buffering. Recorded", arrBufferingsInfo.length);
        }
				else
				{
					showlog(INFO, fn, "Duration is ", nDuration);
				}
			}
			else
			{
				showlog(WARN, fn, "Buffer already recorded. ", nDuration);
			}
		} catch (err)
		{
			showlog(ERROR, fn, err.description, err)
		}
}

function fnChangeMedia(sourceURL) {
	//it's can happen within the same URL so check if exist the diff in URLs
	
	if ( sourceURL != sCurrentPlayURL )
	{
		var sEvent = ""; sEvent = fnItemOnEnd(evIViVoMoveNextItemAnyReason, sCurrentPlayURL, true);
		var res = new EventResult(sEvent, null, null);
		showlog(WARN, "fnChangeMedia", res.GetMessage(), (res.GetHook() != null ? "defined" : "null"));
		return res;
	}
}
function fnReportStatistic() {
	var fn = "fnReportStatistic";
	showlog(INFO, fn, "ItemInfo updates", lNumOfAverageBandwidthUpdates, "avg bw", lCurrItemAverageBandwidth, "lCurrItemPacketsReceived", lCurrItemPacketsReceived, "lCurrItemBitRate", lCurrItemBitRate);

	try {
		if ( bMonitoring ) StopMonitoringItemInfo();
	}
	catch (err)
	{
		showlog(ERROR, fn, err.description, err);
		printStackTrace();
	}
	
	//recorder recent bufering
	fnBufferingContinous(true);
	LostPacketsStopChecking();
	if ( true == GetEventStatus(evIViVoStartBuffering) )
	{ 
		SendAndClearRecordedBufferings();
	}
	else
	{
		showlog(DEBUG, fn, "Skip VI stat on missing 32 event");
	}
	
	SendAndClearRecordedDisruptionSessions();
}
function FilterOutEventsForStoppedItem(type, state, url)
{
	var fn = "FilterOutEventsForStoppedItem";
	var bRet = true;
	
	try
	{
		if ( 0 < sStoppedItem.length )
		{
			switch(type)
			{
				case evPlayState:
				{
					switch(state)
					{
						case pStateTransitioning:
							showlog(INFO, fn, "Garbage events filtered out", url);
							return bRet;
						case pStateStopped:
							if ( null != sStoppedItem.match(url) )
							{
								showlog(WARN, fn, "Stop event filtered out for already stopped", url);
								return bRet;
							}
						default:break;
					}
				}
						
				case evOpenState:
				{
					switch(state)
					{
						case oStateMediaChanging:
							showlog(INFO, fn, "Garbage events filtered out", url);
							return bRet;
						default:break;
					}
				}	
				default:break;
			}//switch(type)
		}//	if ( 0 < sStoppedItem.length )
	}
	catch(err)
	{
		showlog(ERROR, fn, err.description, err);
	}
	
	bRet = false;
	return bRet;
}

function event_dispatcher(type, state, url) {
	fn = "event_dispatcher";
	
	var eventType = "unknown";
	var stateName = state;
	var bRequireURL = true;
	var sLastOperation = "";
		
	stateName = GetStateName(type, state);
	
	switch(type)
	{
		case evPlayState:
		{
			switch(state)
			{
				case pStateReady:
						showlog(INFO, fn, "Not required URL");
						bRequireURL = false;
						break;
				default:break;
			}
			break;
		}
		case evOpenState:
			break;
		case evBuffering:
			state = (state == true ? 1 : 0);
			break;
		case evChangeMedia:
			state = 0;
			break;
		default:break;
	}
		
	try
	{
		showlog(DEBUG, fn, (bIgnoreWholeSession?"IGNORED":"PROCESSED"), "--", sEventType[type].toUpperCase(), "::", stateName.toUpperCase(), "for", url);
		
		if ( true == bIgnoreWholeSession )
		{
			showlog(debug, fn, "bIgnoreWholeSession");
			return null;
		} 
		
		if ( true == bLoggoffProcedure )
		{
			showlog(debug, fn, "bLoggoffProcedure");
			return null;
		} 
		
		if ( true == FilterOutEventsForStoppedItem(type, state, url) ) return null;
		
		if ( wmp == null || wmp == undefined) wmp = analyzer_getAnalyzerObject(objDocPlayer);

		try
		{
			if ( false == RelayNetMode() )
			{
				if ( undefined != objDocPlugin && 0 < objDocPlugin.length ) 
				{
					oPlugin = analyzer_getAnalyzerObject(objDocPlugin);
					if ( true == RelayNetMode() )
					{
						showlog(INFO, fn, "Connected to RelayNet plugin");
					}
				}
				else
				{
					showlog(WARN, fn, "RelayNet plugin not defined. Non RelayNet mode");
				}
			}
			else
			{
				//showlog(INFO, fn, "Already connected to RelayNet plugin");
			}
		}
		catch (err)
		{
			showlog(INFO, fn, sEventType[type], stateName, " Handle RelayNet mode");
			printStackTrace();
		}
		
		var sSourceURL = "";
		
		try	
		{	
			if ( undefined != url )
				sSourceURL = url;
			else
				sSourceURL = wmp.currentMedia.sourceURL;
			
			showlog(INFO, fn, sEventType[type], stateName, wmp.currentMedia.name , sSourceURL);
		} 
		catch(err)
		{
			showlog(WARN, fn, sEventType[type], stateName, "No current media", err.description, err);
			printStackTrace();
		}
			
		try
		{
			if ( bRequireURL == true && sSourceURL.length == 0 )
			{
				showlog(DEBUG, fn, sEventType[type], stateName, "require source URL, no event filled.");
				return;
			}
		}
		catch(err)
		{
			showlog(WARN, fn, sEventType[type], stateName, " in check bRequireURL == true && sSourceURL.length == 0");
			printStackTrace();
		}
			

		if ( DispatchTable[type*100+state] != undefined )
		{	
			try 
			{
				var objEventResult = DispatchTable[type*100+state](sSourceURL, state);
			}
			catch (err)
			{
				showlog(ERROR, fn, sEventType[type], stateName, "Failed callback to dispatch", err.description);
				printStackTrace();
			}

			try
			{
				if ( 1 == nWaitForRealyNetWork )
				{
					showlog(INFO, fn, sEventType[type], stateName, " filtered out in RelayNet mode");
					return;
				}

				if ( oSuspendedEvent != null && oSuspendedEvent.IsFilled() ) //while waiting 32 in RelayMode
				{
					showlog(DEBUG, "event_dispatcher. Send suspended event");
					post(oSuspendedEvent.GetMessage(), oSuspendedEvent.GetData(), oSuspendedEvent.GetHook());
					oSuspendedEvent = null;
				}	
			}
			catch (err)
			{
				showlog(ERROR, fn, sEventType[type], stateName, " in RelayNet handaling", err.description);
				//printStackTrace();
			}
			
			try {
				if ( objEventResult != null && objEventResult.IsFilled() ) 
				{
					post(objEventResult.GetMessage(), objEventResult.GetData(), objEventResult.GetHook());
				}
				else 
				{
					showlog(DEBUG, "event_dispatcher. No event was filled for sending", sEventType[type], stateName);
				}
			}
			catch(err)
			{
				showlog(ERROR, fn, sEventType[type], stateName, " in event sending handaling", err.description, err);
				printStackTrace();
			}				
		}

	
	}
	catch (err)
	{
		showlog(ERROR, fn, sEventType[type], stateName, "Exception in handle", err.description, err);
		printStackTrace();
	}
	
	//in some case after PLAYSTATECHANGE:STOPPED the media 
	//object may be replaced by AJAX so we will lost 
	//connection to callbacks funtiom
	if ( true == IfAJAXLoading() && evPlayState == type && pStateStopped == state )
	{
		nReconnect2Obj = 0;
		g_bInitDone = false;
		wmp = null;
		analyzer_CheckObject();
		showlog(DEBUG, fn, "Watching for player reload. AJAX case")
	}
}

// Common functions for some events
function fnPatchForStartShowMedia()
{
	sProtocol = wmp.network.sourceProtocol;
	showlog(DEBUG, "fnPatchForStartShowMedia sProtocol --> ", sProtocol);
		
	if ( sProtocol == 'Cache' ) 
	{
		var objEventResult = fnBufferingStart(sCurrentPlayURL); //patch for cached items required by server
		if ( objEventResult != null && objEventResult.IsFilled() ) 
		{
			post(objEventResult.GetMessage(), objEventResult.GetData(), objEventResult.GetHook());
		}
		
		SendStartShowMedia();
	}

	DispatchTable[evPlayState * 100 + pStatePlaying] = undefined;
}

function fnItemOnEnd(nEvent, sourceURL, sendReportData) {
	var fn = "fnItemOnEnd";
	var sEvent = ""; 
	var sMoreData = "";
	
	try 
	{
		if ( null != sendReportData && true == sendReportData )
		{
			var nElapsedSize  = 0;
			nElapsedSize = GetMediaElapsedSize(true);
			
			if ( -1 < nElapsedSize )
			{
				sMoreData = "bytes-read=" + nElapsedSize;
			}
			else
			{
				showlog(DEBUG, fn, "skip bytes-read on non positive value");
			}
		}
		
		sEvent = BuildCommonEvent(nEvent, sourceURL, sMoreData);

		BlockStartRestore();

		if ( null != sendReportData && true == sendReportData )
			fnReportStatistic();
		
		sRecentPlayedURL = sCurrentPlayURL;
		sCurrentPlayURL = "";
		
		showlog(DEBUG, "fnItemOnEnd. TotalBytesReceived ", nElapsedSize, "Event", sEvent);
	} catch(err) 
	{
		showlog(ERROR, "fnItemOnEnd", err.description, err);
		printStackTrace();
	}
	return sEvent;
}

function GetMediaElapsedSize(bOnComplete)
{
	var nMediaSize = -1;
	
	try 
	{
		var nDuration =  wmp.currentMedia.getItemInfo("Duration");
		
		if ( nDuration > 0 )
		{
			var posPercent = wmp.controls.currentPosition / nDuration;
			nMediaSize = wmp.currentMedia.getItemInfo("FileSize");

			//on item complete the current position is 0
			if (null == bOnComplete)
				nMediaSize = Math.round(nMediaSize * posPercent);

			showlog(DEBUG, "GetMediaElapsedSize. Item: Duration is", nDuration, posPercent, "% current pos", wmp.controls.currentPosition, "Total", wmp.currentMedia.getItemInfo("FileSize"));
		}
		else
		{
			var nReceivedBytes = GetCurrItemEstimatedReceivedBytes();
			
			if ( !isNaN(nReceivedBytes) || nReceivedBytes > 0 )
				nMediaSize = nReceivedBytes;
			else
				nMediaSize = 0;

			showlog(DEBUG, "GetMediaElapsedSize. Item: Duration is 0. Received bytes from network is", nReceivedBytes);	
		}

		showlog(DEBUG, "GetMediaElapsedSize. Item's size is", nMediaSize);
	} catch (err)
	{
		showlog(ERROR, err.description, err);
		printStackTrace();
	}
	
	return nMediaSize;
}

function SendStartShowMedia()
{
	var fn = "SendStartShowMedia";
	var sEvent = "";
	
	try
	{
		try {
			var sMediaType = wmp.currentMedia.getItemInfo("MediaType");
		}catch(err){ sMediaType = 'video';}
		
		showlog(DEBUG, fn, "media is v:a", sMediaType, GetEventStatus(evIViVoStartVideo), GetEventStatus(evIViVoStartAudio));
		
		if ( (sMediaType == 'video' || sMediaType == 'photo') && false == GetEventStatus(evIViVoStartVideo) )
		{
			sEvent = BuildCommonEvent(evIViVoStartVideo, sCurrentPlayURL);
			if (null != sEvent && 0 < sEvent.length )
			{
        post(sEvent, null, null);
        SetEventStatus(evIViVoStartVideo, true);
				showlog(WARN, "SendStartShowMedia", sEvent);
      }
			
			sEvent = BuildCommonEvent(evIViVoStartAudio, sCurrentPlayURL);
			if (null != sEvent && 0 < sEvent.length )
			{
        post(sEvent, null, null);
				showlog(WARN, fn, sEvent);
				SetEventStatus(evIViVoStartAudio, true);
      }				
		} 
		else if ( sMediaType == 'audio' && false == GetEventStatus(evIViVoStartAudio) )
		{
			sEvent = BuildCommonEvent(evIViVoStartAudio, sCurrentPlayURL);
			if (null != sEvent && 0 < sEvent.length )
			{
				post(sEvent, null, null);	
				showlog(WARN, fn, sEvent);				
				SetEventStatus(evIViVoStartAudio, true);
			}
		}
		else
		{
			showlog(WARN, fn, "Unknown media or statuses v:a", GetEventStatus(evIViVoStartVideo), GetEventStatus(evIViVoStartAudio));
		}
	} catch (err)
	{
		showlog(ERROR, fn, err.description, err);
		printStackTrace();
	}
}

function GetUtcString(dtReceivedDate) {
	var fn = "GetUtcString";
	try
	{
	  if (dtReceivedDate == null)
	  {
	      var dtDateToFormat = new Date(); 
	  }
	  else
	  {
	      var dtDateToFormat = dtReceivedDate;
	  }
	      
	  // create the string containing the formatted date    
	  var sFormatedDate = dtDateToFormat.getUTCFullYear() + "." +
	                      PadWithZeros((dtDateToFormat.getUTCMonth() + 1),2) + "." +
	                      PadWithZeros(dtDateToFormat.getUTCDate(),2) + " " +
	                      PadWithZeros(dtDateToFormat.getUTCHours(),2) + ":" +
	                      PadWithZeros(dtDateToFormat.getUTCMinutes(),2) + ":" +
	                      PadWithZeros(dtDateToFormat.getUTCSeconds(),2) + "." +
	                      PadWithZeros(dtDateToFormat.getUTCMilliseconds(),3);
  } 
	catch (err)
	{
		showlog(ERROR, fn, err.description, err);
		printStackTrace();
	}
	
  return escape(sFormatedDate);               
}
// this function pads a string with leading zeroes
function PadWithZeros(num, count) { 
    var numZeropad = num + '';
    while(numZeropad.length < count) 
    {
        numZeropad = "0" + numZeropad; 
    }
    return numZeropad;
} 
 function itoa(val, base) {
   var ch, ret = "";
   
   if ( base == null) base = 10;
   
   do
   {
     ch = val % base;
     if (ch >= 10) ch = String.fromCharCode(55 + ch);
	 ret = ch + ret;
     val = (val - val % base) / base;
   } while (val > 0);
  
   return ret;
 }

// this class holds the info of one lost packets poll 
function LostPacketsPollInfo(dtStartTime, lNumOfLostPackets) {
    this.dtStartTime = dtStartTime; // start time of the poll
    this.lNumOfLostPackets = lNumOfLostPackets; // num of lost packets in the poll
    
    // getters and setters
    this.GetStartTime = function()
    {
        return this.dtStartTime;
    };
    
    this.SetStartTime = function(value)
    {
        this.dtStartTime = value;
    };

    this.GetNumOfLostPackets = function()
    {
        return this.lNumOfLostPackets;
    };
    
    this.SetNumOfLostPackets = function(value)
    {
        this.lNumOfLostPackets = value;
    };
}
// this class holds the info of the summery of one full disruption session  
function DisruptionSessionsSummary(dtStartTime, lDuration) {
    this.dtStartTime = dtStartTime; // start time of the session
    this.lDuration = lDuration; // // duration of the session
    
    // getters and setters
    this.GetStartTime = function()
    {
        return this.dtStartTime;
    };
    
    this.SetStartTime = function(value)
    {
        this.dtStartTime = value;
    };

    this.GetDuration = function()
    {
        return this.lDuration;
    };
    
    this.SetDuration = function(value)
    {
        this.lDuration = value;
    };
}

function IsActivePlayState(state)
{
	var fn = "IsActivePlayState";
	var bRet = false;
	try {
		if ( state > pStateStopped && state != pStateReady && state != pStateMediaEnded ) bRet = true;
	} catch (err)
	{
		showlog(ERROR, fn, err.description, err);
		printStackTrace();
	}
	return bRet;
}

// this function checks once in an interval how many packets were lost, and saves the info
// in Disruption Sessions. Disruption Sessions are later recorded in the recorded Disruption Sessions array
function CheckLostPackets() {
    var dtCurrTime = new Date();
	//showlog(DEBUG, "CheckLostPackets. Checking... bFirstCheck", bFirstCheck, "lostPackets", wmp.network.lostPackets);
    
    // update the curr item info. we monitor this info since we can't retrieve it on stop event
    // and for the "item info" messages
    UpdateCurrItemInfo();
     
    // if this is the first check go straight to saving the info
    if (bFirstCheck)
    {
        bFirstCheck = false;
    }
    // if not first check - start comparing
    else
    {
        // checking if the current num of lost packets is bigger then the previous one if bigger - continue recording the session
        var nRecentLoss = wmp.network.lostPackets;
        if (nRecentLoss > arrCurrDisruptionSession[lNextCell].GetNumOfLostPackets())
        {
            // if next cell is already 1 it means this is the second straight poll with changes in lost packets  
            if (lNextCell == 1)
            {
                // set save session flag and continue to save in second cell
                bSaveSession = true;
            }
            // if next cell is not 1 it means this is the first poll with changes in lost packets
            else
            {
                // start saving in second cell
                lNextCell = lNextCell + 1;
            }
        }
        else
        {
            // if no new lost packets - finish the session
            FinishSession();            
        }

     }

    // record the current time and num of lost packets
    arrCurrDisruptionSession[lNextCell].SetStartTime(dtCurrTime);
    arrCurrDisruptionSession[lNextCell].SetNumOfLostPackets(wmp.network.lostPackets);
	
	if ( wmp.network.lostPackets > 0 ) 
	{
		showlog(DEBUG, "CheckLostPackets", wmp.network.lostPackets);
	}
	
  // call this function again after an interval (infinate loop)
	if ( true == IsActivePlayState(wmp.playState) || pStateBuffering == wmp.playState )
	{
		oCheckingLostPackets = setTimeout("CheckLostPackets()",MONITORING_PACKETS_INTERVAL);
	}
	else
	{
		showlog(DEBUG, "CheckLostPackets stopped. PlayState is", sPlayState[wmp.playState], IsActivePlayState(wmp.playState));
		bCheckingLostPackets = false;
	}
}
// this function starts the process of checking for lost packets every set interval
function LostPacketsStartChecking() {
	
	// if not already checking
    if (!bCheckingLostPackets)
    {
				showlog(DEBUG, "LostPacketsStartChecking is started.");
        // start checking
        oCheckingLostPackets = setTimeout("CheckLostPackets()",MONITORING_PACKETS_INTERVAL);
        bCheckingLostPackets = true;
    }
	else 
	{
			showlog(ERROR, "LostPacketsStartChecking already is running.");
	}
}
// this function stops the infinate loop of checking for lost packets 
function LostPacketsStopChecking() {
    // if checking 
	showlog(DEBUG, "LostPacketsStopChecking");
	
    if (bCheckingLostPackets)
    {
        // stop checking
        clearTimeout(oCheckingLostPackets);
        bCheckingLostPackets = false;
        
        // finish the current session. this makes sure that if we stop in the middle of a 
        // session, the info will still be recorded 
        FinishSession();
        
        bFirstCheck = true;
        lNumOfAverageBandwidthUpdates = 0;
        lCurrItemAverageBandwidth = 0;
    } 
	else 
	{
			showlog(DEBUG, "LostPacketsStopChecking check not in use.");
	}
}
// this function closes the current disruption session and records it if necessary
function FinishSession() {
	//showlog(DEBUG, "FinishSession Save session", bSaveSession);
	
    // checking if session should be recorded
    if (bSaveSession)
    {    
        //record the session
        RecordDisruptionSession();
    }
    
    bSaveSession = false;
    
    // make the next cell pointer point to the first cell (starting a new session)
    lNextCell = 0;
}

// this function records Disruption Sessions in the recorded Disruption Sessions array
function RecordDisruptionSession() {
	showlog(DEBUG, "RecordDisruptionSession");
	
    var dtStartTime = arrCurrDisruptionSession[0].GetStartTime(); // get the current session start time
    var lDuration = arrCurrDisruptionSession[1].GetStartTime().getTime() - arrCurrDisruptionSession[0].GetStartTime().getTime(); // calc the session's duration 
    var dssSummery = new DisruptionSessionsSummary(dtStartTime,lDuration); // create the session summery object 
    arrRecordedDisruptionSessions[arrRecordedDisruptionSessions.length] = dssSummery; // add this object to the recorded sessions array
}

function ResetItemCounter()
{
	showlog(DEBUG, "ResetItemCounter");
	
	lCurrItemTotalPlaySeconds = 0;
	lNumOfAverageBandwidthUpdates = 0;
	lCurrItemAverageBandwidth = 0;
	lNextCell = 0;
	lBuferCounterInItem = 0;

	arrCurrDisruptionSession.length = 0;
	arrRecordedDisruptionSessions.lenght = 0;

	arrCurrDisruptionSession[0] = new LostPacketsPollInfo(); // set first cell 
	arrCurrDisruptionSession[1] = new LostPacketsPollInfo(); // set second cell

	bFirstCheck = true;
}

// this function updates the vars holding the current item info using the WMP API 
function UpdateCurrItemInfo() {

    // if current bandWidth is not 0 
    if (wmp.network.bandWidth != 0)
    {
        // update the bandwidth average
        lCurrItemAverageBandwidth = ((lCurrItemAverageBandwidth * lNumOfAverageBandwidthUpdates) + wmp.network.bandWidth) / (lNumOfAverageBandwidthUpdates + 1)
        //update the number of updates counter
        lNumOfAverageBandwidthUpdates += 1;
    
    
		// only if playing or buffering update the info (otherwise might override with invalid info)
		if (wmp.playState == pStatePlaying || wmp.playState == pStateBuffering)
		{
			// we monitor this info since we can't retrieve it on stop event
			lCurrItemPacketsReceived = wmp.network.receivedPackets;
			lCurrItemPacketsRecovered = wmp.network.recoveredPackets; 
			lCurrItemBitRate = wmp.network.bitRate;
			
			// only if currently playing update the total play time
			if (wmp.playState == 3)
			{
				lCurrItemTotalPlaySeconds += MONITORING_PACKETS_INTERVAL / 1000;
			}
		}
	
	
		showlog(INFO, "UpdateCurrItemInfo.wmp bw -->", wmp.network.bandWidth, "updates", lNumOfAverageBandwidthUpdates, "avg bw", lCurrItemAverageBandwidth,	"lCurrItemPacketsReceived", lCurrItemPacketsReceived, "lCurrItemBitRate", lCurrItemBitRate);
	
	}
	else
	{
			showlog(DEBUG, "UpdateCurrItemInfo wmp.network.bandWidth is 0");
	}
}
// this function returns the estimated number of bytes the current item RECEIVED so far
function GetCurrItemEstimatedReceivedBytes() {
	var lTotalBytes = -1;
	try
	{
		// calc estimated packet size using saved item info
		var lPacketSize = GetPacketSizeEstimation(lCurrItemPacketsReceived, lCurrItemAverageBandwidth, lCurrItemTotalPlaySeconds);
		// calc total bytes RECEIVED using packet size 
		lTotalBytes = Math.round(lPacketSize * lCurrItemPacketsReceived);
		showlog(DEBUG, "GetCurrItemEstimatedReceivedBytes -->", lTotalBytes);
	} catch(err) 
	{ 
		showlog(ERROR, "GetCurrItemEstimatedReceivedBytes", err.description, err); 
		printStackTrace();
	}
	
	return lTotalBytes;
}
// this function returns the estimated number of bytes the current item RECOVERED so far
function GetCurrItemEstimatedRecoveredBytes() {
	var lTotalBytes = -1;
	try
	{
		//calc estimated packet size using saved item info
		var lPacketSize = GetPacketSizeEstimation(lCurrItemPacketsReceived, lCurrItemAverageBandwidth, lCurrItemTotalPlaySeconds);
		// calc total bytes RECOVERED using packet size 
		lTotalBytes = Math.round(lPacketSize * lCurrItemPacketsRecovered);
    } catch(err) 
	{ 
		showlog(ERROR, "GetCurrItemEstimatedReceivedBytes", err.descrition); 
		printStackTrace();
	}
	
    return lTotalBytes;
}
// this function sends the information in the recorded disruption sessions array and clears it
function SendAndClearRecordedDisruptionSessions() {
	var fn = "SendAndClearRecordedDisruptionSessions"; 
  var dtCurrTime = new Date(); 
  var sDisruptionSessionsMessageBody = "";		
	
    // if there are Recorded Disruption Sessions in the array, send a message with the collected info
    if (null != arrRecordedDisruptionSessions && arrRecordedDisruptionSessions.length > 0)
    {
      // creating the message body by looping over the Recorded Disruption Sessions array
      for(var index = 0; index < arrRecordedDisruptionSessions.length; index++)
      {
          // if not first item - add ','
          if (index > 0) 
          {
              sDisruptionSessionsMessageBody = sDisruptionSessionsMessageBody + ",";
          }
          
          // add the session info to the message
          sDisruptionSessionsMessageBody = sDisruptionSessionsMessageBody + GetUtcString(arrRecordedDisruptionSessions[index].GetStartTime()) + "," + arrRecordedDisruptionSessions[index].GetDuration();
      }
      
      // creating the request params string and sending the message
	    var sData2Insert = "timer-alias=disruption&timer-count=" + lItemsInPlaylistCounter + "&timer-timeout=1000&startTime=" + GetUtcString(dtCurrItemStartTime);
			var sEvent = BuildEventEx(-1, sCurrentPlayURL, sData2Insert);
  
      // clearing the Recorded Disruption Sessions array
      arrRecordedDisruptionSessions = new Array(0);
		
			showlog(INFO, fn, sEvent, sDisruptionSessionsMessageBody);
			post(sEvent, sDisruptionSessionsMessageBody, null);
    }
	else 
	{
		showlog(DEBUG, fn, "No data.");
	}
}
// this function returns an estimation of the packet size in bytes based on num of packets,
// bitrate and num of seconds
function GetPacketSizeEstimation(lPackets, lBitrate, lSeconds) {
	
	var bytesInPacket = -1;
	try {
		if (lSeconds == 0 || lPackets == 0)
		{
			return 0;
		}
	   
		var packetsInSec = lPackets/lSeconds;
		var bytesInPacket = lBitrate/packetsInSec/8;
		
		showlog(DEBUG, "GetPacketSizeEstimation. lPackets: ", lPackets, ". lBitrate", lBitrate, ". lSeconds", lSeconds, ". Rate: ", packetsInSec, ". Packet size:", bytesInPacket);
    }
	catch (err) 
	{ 
		showlog(ERROR, "GetPacketSizeEstimation", err.descrition); 
		printStackTrace();
	}
	
    return bytesInPacket;
}

function postInProgress( xhr ) {
  try
  {
    showlog(DEBUG, "isPostInProgress", xhr.readyState);
    switch( xhr.readyState ) {
      case 1:
      case 2:
      case 3:  return true;
   }
  }
  catch(err)
  {
    showlog(ERROR, "isPostInProgress", err.description, err);
  }
  
  return false;
} 

function postAborting(xhrRequest) {
  
  showlog(DEBUG, "postAborting", xhrRequest); 
  if (postInProgress (xhrRequest)) 
  {
    xhrRequest.abort();
    showlog(FATAL, "postAborting");
    clearTimeout(postTimeoutID);
  }
}

function postGetQueueMessage()
{
	if ( null != arrMessages && undefined != arrMessages )
  	return arrMessages.pop();
  else
  	return null;
}

function postQueueProcessing()
{
  var fn = "postQueueProcessing";
  var oMessage;
  
  if ( null == arrMessages || undefined == arrMessages ) return;
  
	bPostDispatcherRunning = true;

	if ( false == bIgnoreWholeSession && undefined != (oMessage = postGetQueueMessage()))
	{
	  post(oMessage.GetMessage(), oMessage.GetData(), oMessage.GetHook(), true);
	}

  bPostDispatcherRunning = false;
	showlog(DEBUG, fn, "postQueueProcessing complete. bIgnoreWholeSession", bIgnoreWholeSession, "Message queue size is ", arrMessages.length);
}

function ClearSessionSuspend()
{
  var fn = "ClearSessionSuspend";
  
  clearTimeout(hSessionDurationLimitID);
  hSessionDurationLimitID = null;
  g_bSessionSuspended = false;
  bLiveSession = true;
  
  showlog(DEBUG, fn, "Clearing session delay limit", SESSION_MIN_DURATION/1000, "sec");
  postQueueProcessing();
}

//return true if stop processing the message by the caller
function postPreprocessing(sRequestParameters, sMessage, postHandleResponse)
{
  var bRet = true;
  var fn = "postPreprocessing";
  var sQueueReason = "";
  var bStartPosting = false;
  
  do
  {
      if ( true == g_bSessionSuspended )
      {
        if ( null == hSessionDurationLimitID )
        {
          showlog(DEBUG, fn, "Starting session limit delay for", SESSION_MIN_DURATION/1000, "sec");
          hSessionDurationLimitID = setTimeout(ClearSessionSuspend, SESSION_MIN_DURATION);
        }
        
        /*//block it for a while because message does not enough to send or lock the script on unload
        if ( null != sRequestParameters.match("event=32") )
        {
          showlog(WARN, fn, "Switch to live session on 32 while start delay", SESSION_MIN_DURATION/1000, "sec");
          clearTimeout(hSessionDurationLimitID);
          ClearSessionSuspend();
        }
        */
        
        if ( null != sRequestParameters.match("event=33") || null != sRequestParameters.match("event=36") )
        {
          showlog(WARN, fn, "Final event while session start delay", SESSION_MIN_DURATION/1000, "sec");
          arrMessages = null;
          clearTimeout(hSessionDurationLimitID);
          hSessionDurationLimitID = null;
          g_bSessionSuspended = true;
          //bIgnoreWholeSession = true;
          return bRet;
        }
        
        sQueueReason = "SUSPEND";
        break;
      }
      else
      {
        showlog(DEBUG, fn, "Start posting on duration limit expired");
      }
   
      //if exist messages in queue post the message queue
      if ( null != arrMessages && 0 < arrMessages.length ) 
      {
        sQueueReason = "PREVMSG_ARR";
        break;
      }
      
      //if exist message while processing post the message queue
      if ( null != g_xhrRequest || undefined != g_xhrRequest ) 
      {
        sQueueReason = "PREVMSG_HNDL";
        break;
      }
      
      bRet = false;
  }while(false);
  
  if ( true == bRet)
  {
    oMessage = new EventResult(sRequestParameters, sMessage, postHandleResponse);
    if ( null == arrMessages || undefined == arrMessages ) arrMessages = new Array();
    arrMessages.unshift(oMessage);
    
    showlog(DEBUG, fn, "QUEUED:", sQueueReason, varPostURL, "?", sRequestParameters, (postHandleResponse != null ? "defined" : "null"));
  }

  if ( true == bStartPosting )
  {
    if ( null != arrMessages || 0 < arrMessages.length )
    {
      postQueueProcessing();
    }
  }
  
  showlog(DEBUG, fn, "bRet", bRet, "bStartPosting", bStartPosting);
  return bRet;
}

// this function sends a request to the server
function post(sRequestParameters, sMessage, postHandleResponse, bByPass) {
  var fn = "post";
  
  if ( undefined == bByPass || false == bByPass )
  {
    if ( true == postPreprocessing(sRequestParameters, sMessage, postHandleResponse) ) return;
  }
  else
  {
    showlog(DEBUG, fn, "Bypassing postPreprocessing");
  }
  
  if ( null == sRequestParameters.match("urlsid=") && null == sRequestParameters.match("event=7") )
  {
    showlog(DEBUG, fn, "Added urlsid", strGetURLID());
    sRequestParameters = strGetURLID() + sRequestParameters;
  }
  
  showlog(DEBUG, fn, varPostURL, "?", sRequestParameters, (postHandleResponse != null ? "defined" : "null"));  		       
  try 
	{ 
		g_xhrRequest = new XMLHttpRequest();
		//showlog(INFO, "posting --> XMLHttpRequest");
	} 
  catch (e) 
  {
		try 
    { 
			g_xhrRequest = new ActiveXObject('Msxml2.XMLHTTP');
			//showlog(INFO, "posting --> Msxml2.XMLHTTP");
		} catch (e) 
    {
			try 
      { 
				g_xhrRequest = new ActiveXObject('Microsoft.XMLHTTP');
				//showlog(INFO, "posting --> Microsoft.XMLHTTP");
			} 
      catch (e) 
      {
				showlog(ERROR, fn, "posting in creare XMLHTTPRequest");
				printStackTrace();
				g_xhrRequest = null;
      }
    }
	}
	
  try
  {     
  	if ( g_xhrRequest )
  	{
  	  var fnAbort = function() { postAborting(g_xhrRequest); };
      postTimeoutID = setTimeout( fnAbort, nPostTimeout );
  	  //postTimeoutID = setTimeout("postAborting(" + g_xhrRequest + ");", nPostTimeout);
  	  
      // set the request url
			var sUrl = getProxyURL(varAnalyzerID) + "?ivivoposturl=" + sIvivoPostURL + "&" + sRequestParameters;
			//var sUrl = varPostURL + "?ivivoposturl=" + sIvivoPostURL + "&" + sRequestParameters;
      
      if ( null != postHandleResponse )
      {      
        g_xhrRequest.onreadystatechange = function() { postHandleResponse(g_xhrRequest); };
      }
      else
      {
        g_xhrRequest.onreadystatechange = function() { postHandleResponseStub(g_xhrRequest); };
        showlog(DEBUG, fn, "set default response handle");
      }       
      
      g_xhrRequest.open("POST", sUrl, true); 
      
  		var nLen = 0;
  		sForm = "";
  		if ( sMessage != undefined ) 
  		{
  			sForm = escape(sMessage);
  		}
  		
  		try {
  			//showlog(DEBUG, "posting in create XMLHTTPRequest", nLen);
  			g_xhrRequest.setRequestHeader('Content-Type','application/x-www-form-urlencoded');
  		}
  		catch (err)
  		{
  			showlog(ERROR, fn, err.description, err);
  			printStackTrace();
  		}
  		
  		g_xhrRequest.send(sForm);
  	}
  }
  catch(err)
  {
    clearTimeout(postTimeoutID); 
    g_xhrRequest = null;
		showlog(ERROR, fn, "while posting", err.description, err);
		printStackTrace();
  }
}

function postHandleResponseStub(xhrRequest)
{
  try {
    if ( xhrRequest.readyState == 4 || xhrRequest.readyState == "complete" )
    {
      clearTimeout(postTimeoutID); 
      showlog(INFO, "postResponseStub request responded and cleared");
      g_xhrRequest = null;
      postQueueProcessing();
    }
  }
  catch(err)
  {
    showlog(ERROR, "postResponseStub", err.description, err);
  }
}
 // this function uses the response for the xhrRequest to init the session ID
 // this function uses the response for the xhrRequest to init the session ID
function SetURLSessionID(xhrSourceRequest) {
  var fn = "SetURLSessionID";
  try
  {
    if (null == xhrSourceRequest ) return;
    
    try 
    {      
     showlog(INFO, fn, xhrSourceRequest.status, "State:", xhrSourceRequest.readyState, "Text:", xhrSourceRequest.responseText);
    }
    catch(err){return;}

    if ( xhrSourceRequest.readyState != 4 && xhrSourceRequest.readyState != "complete" )
    {
      showlog(INFO, fn, "Waiting for request complete. State", xhrSourceRequest.readyState);
      return;
    }
    
    if ( 200 == xhrSourceRequest.status )
    {
      clearTimeout(postTimeoutID);
      varURLID = "";
      var sTmp = xhrSourceRequest.responseText;
    	// saving the received session id in the global var
      if (null != sTmp.match("URLSessionID="))
      {
          varURLID = sTmp.match(/\d+\s*$/g);
      }
      else
      {
        showlog(WARN, fn, "Non expected data in response");
      }
		}
		else
		{
		  showlog(ERROR, fn, "Error returned", xhrSourceRequest.status);
		  bIgnoreWholeSession = true;
		  varURLID = "";
		  return;
    }
    
  	if ( null == varURLID || 0 == varURLID.length ) 
    {
      showlog(WARN, fn, "Not found ID in response");
      bIgnoreWholeSession = true;
    }
    else
    {
      showlog(DEBUG, fn, "Recieved session ID", varURLID);
      g_xhrRequest = null;
      postQueueProcessing();
    }
  }
  catch(err)
  {
    bIgnoreWholeSession = true;
    // problem handling response 
		showlog(ERROR, fn, err.description, err);
    printStackTrace();
  }
}

// this is a class which keeps the buffering information  
function BufferingInfo(dtStartTime, lDuration) // constructor
{
	this.bIsRecorded = false;
  this.dtStartTime = dtStartTime; // start time of the buffering
  this.lDuration = lDuration; // duration of the buffering
  
  // getters and setters
  this.GetStartTime = function()
  {
      return this.dtStartTime;
  };
  
  this.SetStartTime = function(value)
  {
      this.dtStartTime = value;
  };

  this.GetDuration = function()
  {
      return this.lDuration;
  };
  
  this.SetDuration = function(value)
  {
      this.lDuration = value;
  };

	this.IsRecorded = function()
	{
			return this.bIsRecorded;
	};

	this.SetIsRecorded = function(value)
	{
		this.bIsRecorded = value;
	};

}


// this function sends the information in the recorded bufferings array and clears it
function SendAndClearRecordedBufferings()
{
	var fn = "SendAndClearRecordedBufferings";
  var dtCurrTime = new Date(); 
  var sBufferingMessageBody = "";		

	try
	{
	  // chacking if there are recorded buffering info items in the array
	  if (null != arrBufferingsInfo && arrBufferingsInfo.length > 0)
	  {
	  		showlog(DEBUG, fn, "arrBufferingsInfo.length", arrBufferingsInfo.length);
	      // creating the message body by looping over the recorded bufferings array
	      for(var index = 0; index < arrBufferingsInfo.length; index++)
	      {
	      	if ( null == arrBufferingsInfo[index] || undefined == arrBufferingsInfo[index] ) continue;
	      	
          // if not first item - add ','
          if (index > 0) 
          {
              sBufferingMessageBody = sBufferingMessageBody + ","  
          }

					try{
          // adding the start time and duration of the current recorded buffering 
          	sBufferingMessageBody = sBufferingMessageBody + GetUtcString(arrBufferingsInfo[index].GetStartTime()) + "," + arrBufferingsInfo[index].GetDuration();
        	}catch(err){showlog(WARN, fn, "index", index);}
          showlog(DEBUG, fn, "sBufferingMessageBody", sBufferingMessageBody, "index", index);
	      }
	
	      // creating the request params string and sending the message
	    var sData2Insert = "timer-alias=vi&timer-count=" + lBuferCounterInItem + "&timer-timeout=" + MIN_BUFFERING_DURATION_TO_RECORD;
			var sEvent = BuildEventEx(-1, sCurrentPlayURL, sData2Insert);
     
	    // clearing the recorded bufferings array
	    arrBufferingsInfo = new Array(0);
		
			showlog(INFO, fn, sEvent, sBufferingMessageBody);
			post(sEvent, sBufferingMessageBody, null);
	  }     
		else
		{
			showlog(DEBUG, fn, "No VI data.");
		}
	}
	catch(err)
	{
		showlog(ERROR, fn, err.description, err);
		printStackTrace();
	}
}

function SetEventStatus(event, status)
{
	var fn = "SetEventStatus";
	showlog(DEBUG, fn, event, status)
	try 
	{
		if ( status == null )
			arrEventsFlags[event] = false;
		else
			arrEventsFlags[event] = status;
	}
	catch(err)
	{
		showlog(ERROR, fn, err.description, err);
		printStackTrace();
	}

	return status;
}

function GetEventStatus(event)
{
	var status = false;
	
	try 
	{
		if ( null != arrEventsFlags[event] || undefined != arrEventsFlags[event] )
		{
			status = arrEventsFlags[event];
		}
	}
	catch(err)
	{
		showlog(ERROR, err.description, err);
		printStackTrace();
	}

	return status;
}

function ClearEventsSet(bClearPlaylistEvents)
{
	var fn = "ClearEventsSet";
	showlog(DEBUG, fn);
	
	if ( bClearPlaylistEvents != null )
	{
		arrEventsFlags[evIViVoPlaylistPlay] = false;
		arrEventsFlags[evIViVoPlaylistStop] = false;
	}
	
	arrEventsFlags[evIViVoStopItem] = false;
	arrEventsFlags[evIViVoMoveNextItemOnEnd] = false;
	arrEventsFlags[evIViVoStartItem] = false;
	arrEventsFlags[evIViVoMoveNextItemAnyReason] = false;
	arrEventsFlags[evIViVoStartBuffering] = false;
	arrEventsFlags[evIViVoStartVideo] = false;
	arrEventsFlags[evIViVoStartAudio] = false;
	arrEventsFlags[evIViVoStopItem] = false;
	arrEventsFlags[evIViVoPlaylistStop] = false;
	
	arrEventsFlags[evIViVoMonitoring] = false;
}

//Handle Cookies
function createCookie(name,value,days) {
	if (days) {
		var date = new Date();
		date.setTime(date.getTime()+(days*24*60*60*1000));
		var expires = "; expires="+date.toGMTString();
	}
	else var expires = "";
	document.cookie = name+"="+value+expires+"; path=/";
}

function readCookie(name) {
	var nameEQ = name + "=";
	var ca = document.cookie.split(';');
	for(var i=0;i < ca.length;i++) {
		var c = ca[i];
		while (c.charAt(0)==' ') c = c.substring(1,c.length);
		if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length,c.length);
	}
	return null;
}

function eraseCookie(name) {
	createCookie(name,"",-1);
}

function findPlayerID() {
	var fn = "findPlayerID";
	var sFoundCase = "";

	if (objDocPlayer=="")
	{
		showlog(DEBUG, fn, "Objects ->", document.getElementsByTagName("object").length);
		for(var i = 0; i < document.getElementsByTagName("object").length; i++)
		{
			try
			{
				sFoundCase = "CLSID";
				if (document.getElementsByTagName("object")[i].classid.toUpperCase()=="CLSID:6BF52A52-394A-11D3-B153-00C04F79FAA6")
				{
					objDocPlayer=document.getElementsByTagName("object")[i].id;
					break;
				}
				else
				{
					sFoundCase = "lower case application/x-ms-wmp1";
					if (document.getElementsByTagName("object")[i].type.toLowerCase()=="application/x-ms-wmp")
					{
						objDocPlayer=document.getElementsByTagName("object")[i].id;
						break;
					}
					else
					{
						sFoundCase = "lower case application/application/x-oleobject1";
						if (document.getElementsByTagName("object")[i].type.toLowerCase()=="application/x-oleobject")
						{
							objDocPlayer=document.getElementsByTagName("object")[i].id;
							break;
						}
					}
				}
			}
			catch(err)
			{
				sFoundCase = "catch1";
				showlog(WARN, fn, err.description, err);
				try
				{
					sFoundCase = "application/x-ms-wmp2";
					if (document.getElementsByTagName("object")[i].type.toLowerCase()=="application/x-ms-wmp")
					{
						objDocPlayer=document.getElementsByTagName("object")[i].id;
						break;
					}
					else
					{
						sFoundCase = "lower case application/application/x-oleobject2";
						if (document.getElementsByTagName("object")[i].type.toLowerCase()=="application/x-oleobject")
						{
							objDocPlayer=document.getElementsByTagName("object")[i].id;
							break;
						}
					}
				}
				catch(err)
				{
					sFoundCase = "catch2";
					showlog(ERROR, fn, err.description, err);
				}
			}
		}//for
		showlog(DEBUG, fn, "Found objDocPlayer [", objDocPlayer, "] length is ->", objDocPlayer.length, "case", sFoundCase );
	}
}

 
function output(arr) {
  //Optput however you want
  //alert(arr.join("nn"));
  showlog(WARN, "STACK TRACE:  ", arr.join(""));
}

function printStackTrace() {
	return;
  var callstack = [];
  var isCallstackPopulated = false;
  try {
    i.dont.exist+=0; //doesn't exist- that's the point
  } catch(e) {
    if (e.stack) { //Firefox
      var lines = e.stack.split("\n");
      for(var i=0, len=lines.length; i<len; i++) {
        if (lines[i].match(/^\s*[A-Za-z0-9\-_\$]+\(/)) {
          callstack.push(lines[i]);
        }
      }
      //Remove call to printStackTrace()
      callstack.shift();
      isCallstackPopulated = true;
    }
    else if (window.opera && e.message) { //Opera
      var lines = e.message.split("\n");
      for(var i=0, len=lines.length; i<len; i++) {
        if (lines[i].match(/^\s*[A-Za-z0-9\-_\$]+\(/)) {
          var entry = lines[i];
          //Append next line also since it has the file info
          if (lines[i+1]) {
            entry += " at " + lines[i+1];
            i++;
          }
          callstack.push(entry);
        }
      }
      //Remove call to printStackTrace()
      callstack.shift();
      isCallstackPopulated = true;
    }
  }
  if (!isCallstackPopulated) { //IE and Safari
    var currentFunction = arguments.callee.caller;
    while (currentFunction) {
      var fn = currentFunction.toString();
      var fname = fn.substring(fn.indexOf("function") + 8, fn.indexOf("(")) || "anonymous";
      callstack.push(fname);
      currentFunction = currentFunction.caller;
    }
  }
  output(callstack);
}

function OnWmpCommand(comm) 
{
	var fn = "OnWmpCommand";
	
	try
	{
		if (objDocPlayer) 
		{
			if (objDocPlayer != "") 
			{
				showlog(INFO, fn, " eval ", objDocPlayer + "." + comm);
				eval(objDocPlayer + "." + comm);
			}
		}
	}
	catch(err)
	{
		showlog(ERROR, fn, err.description, err);
	}
}
