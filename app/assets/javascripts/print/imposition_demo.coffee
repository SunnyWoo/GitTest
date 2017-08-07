$(document).on 'click', '[data-imposition-demo]', (e) ->
  e.preventDefault()

  $this = $(this)
  $form = $this.parents('form')

  # 防止 meta 被傳入 (utf8, _method, authenticity_token 等 ajax 不需要的東西)
  $meta = $form.last().children().first().remove()

  formData = new FormData($form[0])

  # 補 meta 回去
  $form.prepend($meta)

  uploading = ->
    $this.prop('disabled', true)
    $this.text('上傳資料中...')

  success = ->
    $this.text('資料上傳完畢, 處理完會將結果寄到你的信箱')
    setTimeout(reset, 5000)

  failure = ->
    $this.text('資料上傳失敗 - 請檢查欄位')
    setTimeout(reset, 1000)

  reset = ->
    $this.text('Demo')
    $this.prop('disabled', false)

  uploading()

  $.ajax(
    type: 'POST'
    url: $this.data('impositionDemo')
    data: formData
    processData: false
    contentType: false
  ).then(success, failure)
