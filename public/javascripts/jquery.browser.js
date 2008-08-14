/*

jQuery Browser Plugin
	* Version 2.0 Beta
	* 2008-06-25 15:35:52
	* URL: http://jquery.thewikies.com/browser
	* Description: jQuery Browser Plugin extends browser detection capabilities and can assign browser selectors to CSS classes.
	* Author: Nate Cavanaugh, Minhchau Dang, & Jonathan Neal
	* Copyright: Copyright (c) 2008 Jonathan Neal under dual MIT/GPL license.
	* JSLint: This javascript file passes JSLint verification.
*//*jslint
		bitwise: true,
		browser: true,
		eqeqeq: true,
		glovar: true,
		nomen: true,
		plusplus: true,
		undef: true,
		white: true
*//*global
		jQuery
*/

(function ($, a, b, i, t, u) {
	// Define 'u' as the browser properties string
	u = navigator.userAgent;

	// Define 't' as true
	t = true;

	// Define 'p' as the processing of every name, version, versionNumber, and versionX
	a = function (i) {
		i = { name: i };
		i[i.name] = t;
		return i;
	};
	b = function (n, v) {
		n.version = v;
		n.versionNumber = parseFloat(v, 10);
		n.versionX = v.substr(0, 1);
		n.className = n.name + v.replace(/\s|\.|0+$/g, '');
		n[n.className] = t;
		return n;
	};

	// Define the browser name
	i = a((/(Firefox|Safari|Opera|Camino|Netscape|Flock|iCab|KDE|iCab|Flock|IE)/.exec(u) || ['unknown'])[0].toLowerCase().replace('kde', 'konqueror'));
	// Define '$.browser' with the browser name and the browser version
	$.browser = b(i, ((i.ie === t) ? /MSIE\s([^;]+)/.exec(u) : (i.firefox === t) ? /Firefox\/([A-Za-z0-9\.]+)/.exec(u) : (i.safari === t) ? /Version\/([^\s]+)/.exec(u) : (i.opera === t) ? /Opera\/([^\s]+)/.exec(u) : [0, 0])[1].toString());

	// Define the layout name
	i = a((/(WebKit|Gecko|Opera|IE)/.exec(u) || ['unknown'])[0].toLowerCase().replace('ie', 'trident').replace('opera', ($.browser.versionNumber >= 7) ? 'presto' : 'elektra'));
	// Define '$.layout' with the layout name and the layout version
	$.layout = b(i, ((i.gecko === t) ? /\srv:([^)]+)/.exec(u)[1] : (i.presto === t) ? ($.browser.versionNumber >= 9.5) ? 'futhark' : 'linear_b' : (i.trident === t) ? $.browser.versionNumber : (i.webkit === t) ? /AppleWebKit\/([^\s]+)/.exec(u)[1] : 1).toString());

	// Define the OS name
	$.os = {
		name: (/(Win|Mac|Linux|SunOS|Solaris|iPhone)/.exec(navigator.platform) || ['unknown'])[0].toLowerCase().replace('sunos', 'solaris')
	};

	// Attach the browser selectors to the html element
	$('html').addClass([$.os.name, $.browser.name, $.browser.className, $.layout.name, $.layout.className, 'js'].join(' '));
})(jQuery);
if (jQuery.browser.safari == undefined){
	jQuery.browser.safari = false;
}
if (jQuery.browser.mozilla == undefined){
	jQuery.browser.mozilla = false;
}

