#= require plugins/swfobject

jQuery ($) ->
  $(document).on 'page:change',  ->
    $('.embed_youtube').each ()->
      checkStatechange = ->
        if (player = $('#' + _embedId)[0]) == undefined
          return
        try
          currentState = player.getPlayerState()
          if currentState == '0'
            clearInterval timer
            $this.html _prev
        catch err
        return

      $this = $(this)
      prevSize = 'large'
      imgWidth = if $this.data('width') then $this.data('width') else 480;
      imgHeight = if $this.data('height') then $this.data('height') else 360;
      flashVars =
        enablejsapi: 1
        autoplay: 1
        modestbranding: 1
        showinfo: 0
        rel: 0
        controls: 0

      _url = $this.attr('href')
      _info = $this.text()
      _index = $this.parent().index()
      _embedId = 'myytplayer_' + _index
      _playerId = 'ytapiplayer_' + _index
      player = undefined
      timer = undefined
      checkSpeed = 500

      _vid = _url.match('[\\?&]v=([^&#]*)')[1]
      _prevUrl = location.protocol+'//img.youtube.com/vi/' + _vid + '/' + (if prevSize == 'large' then 0 else 2) + '.jpg'
      _prevUrl = $this.data('prevUrl') if $this.data('prevUrl')
      _prev = '<img id="' + _playerId + '" src="' + _prevUrl + '" alt="' + _info + '" title="' + _info + '" width="' + imgWidth + '" height="' + imgHeight + '" />'

      $this.html(_prev).on 'click', 'img', ->
        swfobject.embedSWF location.protocol+'//www.youtube.com/v/' + _vid + '?playerapiid=' + _playerId, _playerId, imgWidth, imgHeight, '8', null, flashVars, { allowScriptAccess: 'always' }, id: _embedId
        timer = setInterval(checkStatechange, checkSpeed)
        false
      return
    return
