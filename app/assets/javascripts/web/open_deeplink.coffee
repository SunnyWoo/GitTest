$(document).on 'ready page:load', ->
  $('.open_deeplink').on 'click', ->
    deeplink_protocol = $(this).data('deeplink-protocol')
    deeplink = $(this).data('deeplink')
    if navigator.userAgent.match(/(iPhone|iPod|iPad);?/i)
      return alert "Please open with Safari." if navigator.userAgent.match(/(CriOS);?/i)
      loadDateTime = new Date
      window.setTimeout (->
        timeOutDateTime = new Date
        if timeOutDateTime - loadDateTime < 5000
          window.location = 'https://itunes.apple.com/tw/app/id898632563'
        else
          window.close()
        return
      ), 25
      window.location = "#{deeplink_protocol}://#{deeplink}"
    else if navigator.userAgent.match(/android/i)
      window.open("android-app://com.commandp.me/#{deeplink_protocol}/#{deeplink}");
