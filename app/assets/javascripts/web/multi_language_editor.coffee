$(document).ready ->
  window.CPA ||= {}
  
  CPA.happyEgg = false
  happyEggCode = [38, 38, 40, 40, 37, 39, 37, 39, 66, 65]
  keyCount = 0
  $(this).on "keydown", (e) ->
    if e.keyCode > 16
      if e.keyCode is happyEggCode[keyCount]
        keyCount++
        if keyCount is happyEggCode.length
          $('.translator-edit').attr('style', 'display:inline-block').addClass('animated rubberBand')
          CPA.happyEgg = true
      else
        keyCount = 0
  return

$(document).on 'ready page:load', ->

  target = $('.translator-edit')
  updateText = ''

  if target?

    if CPA.happyEgg
      $('.translator-edit').attr('style', 'display:inline-block').addClass('animated rubberBand')
    
    target.each (index)->
      id = 'tipContent_' + index
      obj = $(this).prev()
      url = $(this).data('translation-url')
      $(this).attr('data-content', id)
      $(this).after('
        <span id="' + id + '" role="tooltip" class="hide">
        <input class="form-input" id="input-' + id + '" name="translator[value]" type="text" value="' + obj.text() + '">
        <input data-id="' + id + '" data-url="' + url + '" class="btn btn-small translator-update" name="Submit" type="submit" value="Submit">')
      return

    $('.translator-edit').tooltipster
      interactive: true
      contentAsHTML: true
      theme: '.tooltipster-light'
      functionInit: ->
        contentID = '#' + $(this).data('content')
        $(contentID).html()
    
    $(document).on 'change', '.form-input', ->
      updateText = $(this).val()
      elmID = '#' + $(this).attr('id').split('-')[1]
      $(elmID).children('.form-input').attr('value', updateText)

    $(document).on 'click', '.translator-update', ->
      targetID = $(this).data('id')
      targetUrl = $(this).data('url')

      $.ajax
        url: targetUrl
        dataType: "json"
        type: 'put'
        data:
          'translator':
            'value': updateText
        success: (data) ->
          target = $('i[data-content=' + targetID + ']').prev().text(data.value)
        error: (data) ->
          console.log 'Update error!!'

      $('.translator-edit[data-content=' + targetID + ']').tooltipster('content', $('#' + targetID).html())
      $('.translator-edit').tooltipster('hide')

  return