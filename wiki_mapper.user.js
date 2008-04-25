// ==UserScript==
// @name	WikiMapper
// @namespace	http://ben.pixelmachine.org
// @description	makes a graph of your Wikipedia Use
// @include http://en.wikipedia.org/*
// ==/UserScript==

var title_re = /http:\/\/en.wikipedia.org\/wiki\/(.*)$/
var referer
if(document.referrer) {
	referer = title_re.exec(document.referrer)[1]
}
var current = title_re.exec(document.location)[1]

if(referer && current) {
	GM_xmlhttpRequest({method: 'GET',
			url: 'http://localhost:9999/?from=' + escape(referer) +
			'&to=' + escape(current)
			})
} else {
	GM_xmlhttpRequest({method: 'GET',
			url: 'http://localhost:9999/?single=' + escape(current)
			})
}