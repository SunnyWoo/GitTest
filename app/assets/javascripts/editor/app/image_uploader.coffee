# Public: The image uploader class using the File, FileReader API
#
# input - The input element, type is 'file'
#
# examples:
#
#   var file = new ImageUploader(id)
#   file.upload()
#   # => Object{ formData: xx, imgData: xx, prop: 'photo', uuid: xx }
# 
#= require plugins/exif.js

class ImageUploader
  constructor: (id)->
    @image = document.getElementById(id)
    @files = []
    @dataUrl = ''
    @data = {}

  handleFileSelect: (evt) ->
    evt.stopPropagation()
    evt.preventDefault()
    @files = evt.dataTransfer?.files or evt.target?.files

    reader = new FileReader()
    # TODO: JPEG 有可能會把 orientation 儲存在 一般，非 exif
    reader.onload = (e) =>
      getFileOption = @getExif @files[0]
      getFileOption.done (exif) =>
        if exif.Orientation and exif.Orientation > 1
          newImg = new TransformCoordinates(@files[0], e.target.result)
          newImg.getDataUrl().done (result) =>
            @dataUrl = result
            $('#preview_img').attr('src', @dataUrl)
            @ready()
        else
          @dataUrl = e.target.result
          $('#preview_img').attr('src', @dataUrl)
          @ready()
        $('#img_previews .file-name div span').text(@files[0].name)
        $('#img_previews .file-check')
          .html('<i class="fa fa-check"></i>')
          .addClass('animated rubberBand')
        $('#img_previews').removeClass('hide')
        $('.image-ready').removeClass('hide')
        $('.fileinput-button').addClass('hide')

    reader.readAsDataURL(@files[0])
    return

  handleDragOver: (evt) ->
    evt.stopPropagation()
    evt.preventDefault()
    evt.dataTransfer.dropEffect = 'copy'

  renderUuid: ->
    d = new Date().getTime()
    key = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx".replace(/[xy]/g, (c) ->
      r = (d + Math.random() * 16) % 16 | 0
      d = Math.floor(d / 16)
      ((if c is "x" then r else (r & 0x7 | 0x8))).toString 16)
    key

  getUploadData: ->
    @data

  getExif: (file) ->
    deferred = $.Deferred()
    EXIF.getData file, ->
      deferred.resolve(this.exifdata)
    deferred.promise()

  upload: ->
    @image.addEventListener 'dragover', @handleDragOver, false
    @image.addEventListener 'drop', @handleFileSelect.bind(@), false
    @image.addEventListener 'change', @handleFileSelect.bind(@), false

  clear: ->
    @files[0].value = null

  ready: ->
    @data =
      formData: @files[0]
      imgData: @dataUrl
      prop: 'photo'
      uuid: @renderUuid()

$(document).ready ->
  imgFile = new ImageUploader('upload_from_computer')
  imgFile.upload()

  $('.fileinput-button').on 'click', ->
    $('#img_previews .file-check').removeClass('rubberBand')
    $('#upload_img').trigger('click')

  $('.image-ready').on 'click', ->
    img = imgFile.getUploadData()
    $('#img_previews').addClass('hide')
    $(this).addClass('hide')
    $('.fileinput-button').removeClass('hide').attr('disabled', false)
    $('#upload_from_computer').modal('hide')
    cmdp.tmpInputImage = img.formData
    obj =
      data:      img.imgData
      data_name: null
      prop:      img.prop
      uuid:      img.uuid
      exif:      img.exif
    cmdp.addc('upload_img', obj)
    imgFile.clear()
    return

  return
