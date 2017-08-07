#= require designer_store/vendors/editor

$(document).on 'page:change', ->
  $edit_product_template = $('.edit_product_template')
  $edit_product_template.find('input, select').not('.simple_form_image_input, input[name="product_template[settings][font_text]"]')
  .change refreshTemplate
  $('.simple_form_image_input').change previewFile
  $('input[name="product_template[settings][font_text]"]').change refreshTextLayer
  $('.nav-tabs li').on 'click', clickTabHandler
  reloadWholeEditor()

# 新增一層 layer，讓使用者能利用拖曳的方式改變文字的位置
createEditorContentMovingLayer = () ->
  $newLayer = $('<div class="newLayer"><div class="textAreaBorder"><div></div>')

  $('#template_editor').find('.CE-Editor').append($newLayer)
  $('.newLayer').css({
    'position': 'absolute',
    'width': '100%',
    'height':'100%',
    'left': 0,
    'top': 0,
    'cursor': 'pointer'
  })

  # 以 event.target 元件的正中心為原點(0, 0)，取得滑鼠座標相對於此元件寬及高的比例，相當於左上角為(-0.5, -0.5)，右下角為(0.5, 0.5)
  _getPosition = (e) ->
    @$newLayer ||= $('.newLayer')
    offset = @$newLayer.offset()
    width = @$newLayer.width()
    height = @$newLayer.height()

    x: (e.pageX - offset.left) / width - 0.5
    y: (e.pageY - offset.top) / height - 0.5

  # 將滑鼠座標相對於此元件寬及高的比例乘以 product model 的寬及高，換算成 form 裡面的 Position x 及 Position y，並重新刷新此模板
  _setupStartPosition = (mousePosRatio) ->
    setCurrentFormData({
      positionX: mousePosRatio.x * jsPageData.editorData.productWidth
      positionY: mousePosRatio.y * jsPageData.editorData.productHeight
    })

  isFingerMoving = false

  # 使文字位置與滑鼠位置一致，並開始監聽 mousemove 事件
  setupMoveStart = (e) ->
    mousePosRatio = _getPosition(e)
    _setupStartPosition(mousePosRatio)
    isFingerMoving = true

  mouseMoveHandler = (e) ->
    return if !isFingerMoving
    mousePosRatio = _getPosition(e)
    _setupStartPosition(mousePosRatio)

  # 加上 off 停止監聽 mouseup 及 mousedown 後的 mousemove 事件
  setupMoveEnd = (e) ->
    isFingerMoving = false

  $('.newLayer')
    .mousedown setupMoveStart
    .mousemove mouseMoveHandler
    .mouseup setupMoveEnd

getProductModelInfo = () ->
  desiredWidth = 400
  templateWidth = desiredWidth
  templateHeight = desiredWidth / jsPageData.editorData.productWidth * jsPageData.editorData.productHeight

  templateProductRatio = Math.min(templateHeight / jsPageData.editorData.productHeight, templateWidth / jsPageData.editorData.productWidth)

  width: templateWidth
  height: templateHeight
  ratio: templateProductRatio

# 清空編輯器，並利用 option 中的新設定重新產生新的編輯器，
initializeEditor = (option) ->
  templateEditor = document.getElementById('template_editor')
  productModelInfo = getProductModelInfo()
  $(templateEditor).html('')

  editorOptions =
    dimension:
      width: productModelInfo.width
      height: productModelInfo.height
    oauthConfig: jsPageData.editorData.oauthConfig
    qualityText: '印刷品质:'
    defaultWorkName: '測試作品'
    productModel: jsPageData.editorData.productModel
    template:
      maxFontSize: 200
      minFontSize: Math.ceil(12 / productModelInfo.ratio)
      maxWidth: 1000
      fontText: 'Suiside Squad'
      fontName: 'AlwaysForever'
      color: '0x000000'
      positionX: 0
      positionY: -500
      transparent: 1
      orientation: 350

  editor = new CommandP.Editor(
    templateEditor
    _.merge({}, editorOptions, option)
  )
  createEditorContentMovingLayer()
  window.editor = editor
  setCurrentFormData({ minFontSize: editorOptions.template.minFontSize })

_setTextAreaContent = () ->
  template = getDataFromCurrentForm().template
  productModelInfo = getProductModelInfo()
  $block = $('.textAreaBorder')

  $block.css(
    top: template.positionY * productModelInfo.ratio + 0.5 * productModelInfo.height
    left: template.positionX * productModelInfo.ratio + 0.5 * productModelInfo.width
    width: template.maxWidth * productModelInfo.ratio
    height: template.maxFontSize * productModelInfo.ratio
    transformOrigin: "left top"
    fontSize: +template.maxFontSize * productModelInfo.ratio
    fontFamily: template.fontName
    transform: "rotate(#{template.orientation}deg) translate(-50%, -50%)"
  )

# 拿取 form 中的新資料，並更新編輯器
refreshTemplate = (option) ->
  editor.updateTemplate(_.merge({}, getDataFromCurrentForm().template, option ))
  _setTextAreaContent()
# _.throttle( , 500)

# 更新 text 圖層
refreshTextLayer = () ->
  editor.updateTextLayer({ fontText: getDataFromCurrentForm().template.fontText })

# 拿取 form 中的新資料，清空原有編輯器，重新產生編輯器
reloadWholeEditor = (option) ->
  if jsPageData.editorData
    initializeEditor(_.merge({}, getDataFromCurrentForm(), option))
    _setTextAreaContent()
  return

clickTabHandler = () ->
  return if $(this).hasClass('active')
  setTimeout(reloadWholeEditor, 100)

# 拿取 form 中新輸入的資料
getDataFromCurrentForm = (form) ->
  currentForm = form or findCurrentForm()

  TEMPLATE_MAP =
    photo_only: ['photo']
    text_only: ['text']
    text_and_photo: ['text', 'photo']

  formData = $(currentForm).serializeArray().reduce((m,o) ->
    m[o.name] = o.value
    return m
  , {})

  templateImage = currentTemplateImageSrc()

  template_type = formData['product_template[template_type]']
  template:
    templateType: TEMPLATE_MAP[template_type]
    templateImage: templateImage
    maxFontSize: Math.max(+formData['product_template[settings][max_font_size]'], 32)
    maxWidth: Math.max(+formData['product_template[settings][max_font_width]'], 200)
    fontText: formData['product_template[settings][font_text]']
    fontName: formData['product_template[settings][font_name]']
    color: formData['product_template[settings][color]']
    positionX: +formData['product_template[settings][position_x]']
    positionY: +formData['product_template[settings][position_y]']
    # transparent: 1
    orientation: +formData['product_template[settings][rotation]']

# 配合 input file 更新 templateImage url
previewFile = () ->
  file    = this.files[0]
  reader  = new FileReader()

  reader.addEventListener "load", () ->
    editor.updateTemplate({templateImage: reader.result})
    currentTemplateImageSrc(reader.result)
  , false

  if file
    reader.readAsDataURL(file)

  reader.result

findCurrentForm = ->
  currentTabpane = $('#photo_only_form.active')[0] || $('#text_only_form.active')[0] || $('#text_and_photo_form.active')[0]
  currentForm = $(currentTabpane).find('form')[0]

findCurrentTemplateImage = ->
  $('.template_image_url', findCurrentForm())

setCurrentFormData = (data) ->
  currentForm  = findCurrentForm()
  $('#product_template_settings_min_font_size', currentForm).val(data.minFontSize) if data.minFontSize?
  $('#product_template_settings_position_x', currentForm).val(data.positionX) if data.positionX != undefined
  $('#product_template_settings_position_y', currentForm).val(data.positionY) if data.positionY != undefined
  refreshTemplate()

# 更新 templateImage url
currentTemplateImageSrc = (src) ->
  currentTemplateImage = findCurrentTemplateImage()

  if src
    currentTemplateImage.text(src)
  else
    currentTemplateImage.text()
