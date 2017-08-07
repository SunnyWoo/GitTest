$(document).on 'ready page:load', ->
  editorId = 'bd-editor-root'
  editorExUploaderId = 'redeem-works-editor-uploader'

  # mount editor
  editorRoot = $("##{editorId}")
  editorOptions =
    dimension:
      width: editorRoot.width()
      height: editorRoot.height()
    oauthConfig:
      host: editorRoot.data('host')
      accessToken: editorRoot.data('accessToken')
    productModel: editorRoot.data('productModel')
    workUuid: editorRoot.data('workUuid')
  editor = new CommandP.Editor(editorRoot[0], editorOptions)

  # mount extra photo uploader button
  $("##{editorExUploaderId}").on 'change', (e) ->
    editor.setImage(@files[0]) if @files?[0]

  # open editor tab
  $('.redeem-works-editor-container').addClass('poped')

  # open/close preview tab
  $('.redeem-works-preview').on 'click', ->
    lodingView = $('.loading-view-background')
    lodingIcon = $('.loading-view-icon')
    lodingView.removeClass('hide')
    setTimeout (-> lodingIcon.addClass('animated')), 100
    $('.redeem-works-preview-container').addClass('poped')
    editor.save().then (artwork) ->
      editor.loadPreviews().then (previews) ->
        setTimeout (-> lodingView.addClass('hide')), 100
        lodingIcon.removeClass('animated')
        $("img.work-info-avatar").attr 'src', artwork.userAvatars.s35
        $(".work-info-name").text artwork.name
        $(".work-info-username").text artwork.userDisplayName
        $("img#work-gallery-image").attr 'src', previews[0].imageUrl

  $('.redeem-works-preview-back').on 'click', ->
    $('.redeem-works-preview-container').removeClass('poped')

  # back button
  $('.redeem-works-cancel').on 'click', ->
    window.history.go(-1)
