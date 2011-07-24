addInputLabels = (selector) ->
	$(selector).each ->
		this.value = $(this).attr 'title'
		$(this).addClass 'text-label'
		
		$(this).focus ->
			if this.value is $(this).attr 'title'
				this.value = ''
				$(this).removeClass 'text-label'
		$(this).blur ->
			if this.value is ''
				this.value = $(this).attr 'title'
				$(this).addClass 'text-label'

$(document).ready ->
	addInputLabels 'input[type="text"], textarea'
	$.each $('email'), (i, v) ->
		link = $('<a>').attr 'href', 'mailto: ' + $(v).text()
		link.html $(v).text()
		$(v).html link
