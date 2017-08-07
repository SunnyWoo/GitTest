$ ->
  $(document).on 'click', '#work_save_for_later', ->
    console.log $(this).attr('href')
    $.ajax
      url: $(this).attr('href')
      type: 'patch'
    .done (data)->
      if data.status == 'ok'
        $('#alert_notice').modal({ show: true })
      else
        console.log data.message
    return false

  $(document).on 'click', '.work_share_to_fb', ->
    imageUrl = $('.show-box img').eq(0).attr('src')
    FB.ui
      method: 'feed'
      link: 'https://commandp.com/en'
      caption: 'commandp.com'
      picture: imageUrl
      description: 'Create your own custom phone cases with your favorite photos!'
      name: 'Commandp'

    return false

  $(document).on 'click', '.work_share_to_twitter', ->
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