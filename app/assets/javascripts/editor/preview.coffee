previews = new Object()
previewUrls = new Object()
previewTimer = []

@sendCoverImage = ->
  imgData = localStorage.getItem('cmdp_editor_coverImage')
  if imgData?
    url = $('#preview_data').data('coverImagePath')
    timeDiff = 0
    timeStart = null
    timeEnd = null
    deferred = $.ajax(
      url: url
      type: 'PATCH'
      data: {data: imgData}
      beforeSend: =>
        timeStart = moment()
        return
    )
    deferred.done (response) =>
      timeEnd = moment()
      timeDiff = timeEnd.diff(timeStart, 's')
      console.log 'Upload cover image takes', timeDiff, 'seconds.'
      previews = response.previews
      returnUrl = @getAllPreviews(previews)
      return
    deferred.fail (response) =>
      console.log 'Error: !!!', response.responseText
      return

  else
    console.log 'Can not find cover image.'

  return

@loadImage = (preview) ->
  imageLoader = ->
    poller = ->
      ajax = $.ajax(type: 'get', url: preview.path, dataType: 'json')
      ajax.done (data) -> deferred.resolve(key: preview.key, url: data.url)
      ajax.fail -> setTimeout(poller, 1000)
    poller()
  deferred = $.Deferred(imageLoader)
  deferred.promise()

@getAllPreviews = (previews) ->
  imageLoaders = (loadImage(preview) for preview in previews)
  $.when(imageLoaders...).then (images...) ->
    previewCounter.stop()

    for image in images
      imgHTML = "<img class='hide' src='#{image.url}' data-img='#{image.key}'>"
      thumbHTML = "<li data-thumb='#{image.key}'><img class='thumb' src='#{image.url}' data-img='#{image.key}'></li>"
      $('.show-box').append(imgHTML)
      $('.thumb-list ul').append(thumbHTML)
    $('.show-box .rendering').remove()
    $('.thumb-list ul li:first-child').trigger('click')
    $('.add_to_cart').attr('disabled', false)
    $('#work_save_for_later').attr('disabled', false)

previewCounter = new Countdown(
  seconds: 30
  onUpdateStatus: (sec) ->
    $('#preview_counter').html(sec)
    return
)
previewCounter.start()
