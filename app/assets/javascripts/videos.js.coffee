# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).ready ->
	animSpeed = 200
	commentForm = $('#new_comment')
	$('button.reset').hide()
	
	$('a.reply').click (e) ->
		e.preventDefault()
		# set fixed height to prevent scrolling
		$('.comments').css 'height', $('.comments').height()
		
		commentId = $(this).data 'commentid'
		comment = $('.comment#' + commentId)
		replyDiv = $('div#reply' + commentId)
		
		# put parent comment id to hidden input @form
		$('input#comment_parent_id').val commentId
		
		commentForm.slideUp animSpeed, ->
			$(this).prependTo(replyDiv).slideDown animSpeed
			$('button.reset').show()

	$('button.reset').click (e) ->
		e.preventDefault()
		$('#comment_parent').val ''
		commentForm.slideUp animSpeed, ->
			$('button.reset').hide()
			$(this).appendTo($('.comments')).slideDown animSpeed
			
			
	if $('#video_source').length
		$('#video_source').uploadify
			uploader: '/uploadify.swf'
			script: '/upload'
			cancelImg: '/assets/cancel.png'
			auto: true
			buttonText: 'Select file'
			onSelect: ->
				$('span.upload').css 'height', 100
			onComplete: (event, ID, fileObj, response, data) ->
				window.location.href = '/videos/new?filename=' + encodeURIComponent response