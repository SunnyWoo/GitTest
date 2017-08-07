$(document).on 'ready page:load', ->

  $('#going_payment').on 'click', ->
    $('#loading_cover').css(
        width: $(window).width() + 'px'
        height: $(window).height() + 'px'
      ).removeClass('hide')
    return

  $(window).resize ->
  	$('#loading_cover').css(
      width: $(window).width() + 'px'
      height: $(window).height() + 'px'
    )
  	return
		