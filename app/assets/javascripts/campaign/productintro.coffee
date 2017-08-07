$(document).on 'ready page:load', ->

  $page = $('.productintro-page')

  $page.on 'click touch', '.arrow-icon', ->
    $featureItem = $(@).toggleClass('up').parents('.feature-item')
    $content = $featureItem.find('.content')
    $content.toggle()
    if $content.is(':visible')
      $featureItem.css('padding', '20px 0')
    else
      $featureItem.css('padding', '17px 0 13px')


  $page.on 'click touch', '.productintro-header-btn', ->
    action $(@)

  $('#product_intro_kv').on 'click touch', ->
    action $(@)

  action = ($self) ->
    key = $self.data('key')
    open key

  open = (key)->
    deeplink_protocol = 'commandp'
    deeplink = "create?category=#{key}"
    userAgent = navigator.userAgent
    if userAgent.match(/(iPhone|iPod|iPad);?/i)
      if userAgent.match(/(CriOS);?/i)
        alert('Please open with Safari.')
      protocol_uri = deeplink_protocol + '://' + deeplink
      download_url = 'https://itunes.apple.com/tw/app/id898632563'
    else if userAgent.match(/android/i)
      protocol_uri = deeplink_protocol + '://' + deeplink
      download_url = 'https://play.google.com/store/apps/details?id=com.commandp.me&hl=zh_TW'
    check protocol_uri, download_url

  check = (protocol_uri, download_url) ->
    if !protocol_uri or !download_url
      return
    loadDateTime = new Date
    window.setTimeout (->
      timeOutDateTime = new Date
      if timeOutDateTime - loadDateTime < 2000
        window.location = download_url
      else
        window.close()
      return
    ), 500
    window.location = protocol_uri
