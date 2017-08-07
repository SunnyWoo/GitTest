jQuery ($) ->
  imageReader = (file) ->
    defer = $.Deferred ->
      reader = new FileReader()
      reader.onload = (e) -> defer.resolve(e.target.result)
      reader.readAsDataURL(file)
    defer.promise()

  $(document).on 'change', ':file[data-preview-at]', (e) ->
    files = e.target.files
    readers = (imageReader(file) for file in files)
    previewAtId = $(this).data('previewAt')
    $previewAt = $(this).parent().find(previewAtId)
    $previewAt.html('')

    $.when(readers...).then (urls...) ->
      for url in urls
        $previewAt.append("<img src='#{url}' alt=''>")
