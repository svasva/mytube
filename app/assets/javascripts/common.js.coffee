$(document).ready ->
	$.each $('email'), (i, v) ->
		link = $('<a>').attr 'href', 'mailto: ' + $(v).text()
		link.html $(v).text()
		$(v).html link
