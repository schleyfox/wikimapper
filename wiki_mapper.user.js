// ==UserScript==
// @name	WikiMapper
// @namespace	http://code.pixelmachine.org
// @description	makes a graph of your Wikipedia Use
// @include http://en.wikipedia.org/wiki/*
// ==/UserScript==

var title_re = /http:\/\/en.wikipedia.org\/wiki\/(.*)$/
var referer
if(document.referrer) {
	tmp = title_re.exec(document.referrer)
	if(tmp)
		referer = tmp[1]
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
