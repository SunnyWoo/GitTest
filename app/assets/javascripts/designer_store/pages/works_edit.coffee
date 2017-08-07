$(document).on 'page:change', ->
  return if $('body.works_controller.edit_action').length == 0

  new EditorUI('#commandp-editor').init()

class EditorUI
  constructor: (editorID) ->
    @$editorElem = $(editorID)

    @$editorOptionBar = $('[data-widget-editor-option-bar]')
    @$photoUploaderBtn = @$editorOptionBar.find('[data-photo-uploader-btn]')
    @$photoUploader = @$editorOptionBar.find('[data-photo-uploader]')
    @$textBtn = @$editorOptionBar.find('[data-change-text]')
    @$previewBtn = @$editorOptionBar.find('[data-priview-work]')
    @$disabledMask = @$editorOptionBar.find('[data-disabled-mask]')
    @$editorTextBar = $('[data-widget-editor-text-bar]')

    @allowFeatures = [].concat(jsPageData.editorData.template.templateType)

    @_disable = @_disable.bind(this)
    @_enable = @_enable.bind(this)

  init: ->
    @_deleteFeatures()
    @_initEditor()
    @_showOptionBar()
    @_setupEvent()

  _deleteFeatures: ->
    @$photoUploaderBtn.hide() if @allowFeatures.indexOf('photo') == -1
    @$textBtn.hide() if @allowFeatures.indexOf('text') == -1

  _initEditor: ->
    # 在 iOS Facebook App 瀏覽器計算高度不會將下方書籤列與上方網址列計算進去，但實際上會出現，所以要減掉
    editorHeightCropOffset =
      if isInFacebookIOSApp()
        110
      else
        0

    editorDataFromServer = jsPageData.editorData
    editorOptions = {
      dimension: {
        width: @$editorElem.width(),
        height: $(document).height() - @$editorOptionBar.height() - editorHeightCropOffset,
      },
      oauthConfig: editorDataFromServer.oauthConfig,
      qualityText: editorDataFromServer.qualityText,
      workUuid: editorDataFromServer.workUuid,
      defaultWorkName: editorDataFromServer.defaultWorkName,
      productModel: editorDataFromServer.productModel,
      template: editorDataFromServer.template,
      onDisabledCallback: @_disable,
      onEnabledCallback: @_enable
    }

    @editor = new CommandP.Editor(@$editorElem[0], editorOptions)

  _setupEvent: ->
    @_setupOptionEvent()
    @_setupTextEvent()

  _setupOptionEvent: ->
    self = this

    @$photoUploader.change (e) ->
      file = this.files[0]
      return if !file?

      self.editor.setImage(file)

    @$textBtn.click =>
      @_showTextBar()

    @$previewBtn.click (event) ->
      event.preventDefault()

      selfElem = this
      self.editor.save()
        .then =>
          window.location.href = $(selfElem).attr('href')
        .catch (e) =>
          self._showUploadError()

    @$disabledMask.click (e) ->
      e.preventDefault()
      e.stopPropagation()

  _setupTextEvent: ->
    editor = @editor
    textInput = @$editorTextBar.find('[data-text-input]')
    confirmBtn = @$editorTextBar.find('[data-text-confirm]')

    confirmBtn.click =>
      targetValue = textInput.val()

      try
        editor.checkTextContentAvailable(targetValue)

        editor.changeTextContent(targetValue)
        @_hideReachTextWidthLimitError()
        @_showOptionBar()
      catch error
        @_showReachTextWidthLimitError()

  _showOptionBar: ->
    @$editorOptionBar.show()
    @$editorTextBar.hide()

  _showTextBar: ->
    @$editorTextBar.show()
    @$editorOptionBar.hide()

  _showReachTextWidthLimitError: ->
    $('#text-hint').show()

    setTimeout(
      () -> $('#text-hint').fadeOut(),
      3000
    )

  _hideReachTextWidthLimitError: ->
    $('#text-hint').hide()

  _showUploadError: ->
    $('#upload-failed').show()

    setTimeout(
      () -> $('#upload-failed').fadeOut(),
      3000
    )

  _disable: ->
    @$editorOptionBar.addClass('is-disabled')

  _enable: ->
    @$editorOptionBar.removeClass('is-disabled')
