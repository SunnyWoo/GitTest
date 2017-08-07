$ ->
  $(document).on 'click', '.share_fb_feed', ->
    FB.ui
      method: 'feed'
      link: location.href
      message: 'Test123'
    return false

  $(document).on 'click', '.twitter-share-button', ->
  	top = $(window).height()/2 - 150
  	left = $(window).width()/2 - 270
  	window.open(this.href,'targetWindow', 
  		                    'toolbar=no
                           ,location=no
                           ,status=no
                           ,menubar=no
                           ,scrollbars=yes
                           ,resizable=yes
                           ,top=' + top + '
                           ,left=' + left + '
                           ,width=600
                           ,height=300')

  	return false
