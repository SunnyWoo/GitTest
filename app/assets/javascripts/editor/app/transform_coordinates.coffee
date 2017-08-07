# Public: Transform the coordinates of uploading image.
#
# file          - Upload file including exif
# originDataUrl - image dataUrl
# 

class @TransformCoordinates
  constructor: (file, originDataUrl) ->
    @elm = document.createElement('canvas').setAttribute('id', 'transform_img')
    @file = file
    @origin = originDataUrl
    @width = file.exifdata.PixelXDimension
    @height = file.exifdata.PixelYDimension
    @newCanvas = @transform(file.exifdata.Orientation)

  transform: (orientation) ->
    deferred = $.Deferred()
    canvas = new fabric.Canvas('transform_img')
    canvas.setBackgroundColor('transparent', canvas.renderAll.bind(canvas))
    canvas.setHeight(@height)
    canvas.setWidth(@width)
    if !orientation or orientation > 8
      return
    if orientation > 4
      canvas.setHeight(@width)
      canvas.setWidth(@height)
    info = switch orientation
      when 1 then { angle: 0, flipX: false, flipY: false }
      when 2 then { angle: 0, flipX: true, flipY: false }
      when 3 then { angle: 180, flipX: false, flipY: false }
      when 4 then { angle: 180, flipX: true, flipY: false }
      when 5 then { angle: 90, flipX: false, flipY: true }
      when 6 then { angle: 90, flipX: false, flipY: false }
      when 7 then { angle: 270, flipX: false, flipY: true }
      when 8 then { angle: 270, flipX: false, flipY: false }
      else        0
    fabric.Image.fromURL @origin, (img) =>
      imgWidth = img.getWidth()
      imgHeight = img.getHeight()
      img.set(
        width:   imgWidth
        height:  imgHeight
        scaleX:  1
        scaleY:  1
        originX: 'center'
        originY: 'center'
        angle:   info.angle
        flipX:   info.flipX
        flipY:   info.flipY
        top:     0
        left:    0
      )
      canvas.add img
      canvas.setActiveObject img
      deferred.resolve(canvas.getActiveObject().toDataURL())
      return
    , crossOrigin: 'anonymous'
    deferred.promise()

  getDataUrl: ->
    @newCanvas.promise()