#
# * JavaScript Canvas to Blob 2.0.5
# * https://github.com/blueimp/JavaScript-Canvas-to-Blob
# *
# * Copyright 2012, Sebastian Tschan
# * https://blueimp.net
# *
# * Licensed under the MIT license:
# * http://www.opensource.org/licenses/MIT
# *
# * Based on stackoverflow user Stoive's code snippet:
# * http://stackoverflow.com/q/4998908
# 

#jslint nomen: true, regexp: true 

#global window, atob, Blob, ArrayBuffer, Uint8Array, define 
((window) ->
  "use strict"
  CanvasPrototype = window.HTMLCanvasElement and window.HTMLCanvasElement::
  hasBlobConstructor = window.Blob and (->
    try
      return Boolean(new Blob())
    catch e
      return false
    return
  )
  hasArrayBufferViewSupport = hasBlobConstructor and window.Uint8Array and (->
    try
      return new Blob([new Uint8Array(100)]).size is 100
    catch e
      return false
    return
  )
  BlobBuilder = window.BlobBuilder or window.WebKitBlobBuilder or window.MozBlobBuilder or window.MSBlobBuilder
  dataURLtoBlob = (hasBlobConstructor or BlobBuilder) and window.atob and window.ArrayBuffer and window.Uint8Array and (dataURI) ->
    byteString = undefined
    arrayBuffer = undefined
    intArray = undefined
    i = undefined
    mimeString = undefined
    bb = undefined
    if dataURI.split(",")[0].indexOf("base64") >= 0
      
      # Convert base64 to raw binary data held in a string:
      byteString = atob(dataURI.split(",")[1])
    else
      
      # Convert base64/URLEncoded data component to raw binary data:
      byteString = decodeURIComponent(dataURI.split(",")[1])
    
    # Write the bytes of the string to an ArrayBuffer:
    arrayBuffer = new ArrayBuffer(byteString.length)
    intArray = new Uint8Array(arrayBuffer)
    i = 0
    while i < byteString.length
      intArray[i] = byteString.charCodeAt(i)
      i += 1
    
    # Separate out the mime component:
    mimeString = dataURI.split(",")[0].split(":")[1].split(";")[0]
    
    # Write the ArrayBuffer (or ArrayBufferView) to a blob:
    if hasBlobConstructor
      return new Blob([(if hasArrayBufferViewSupport then intArray else arrayBuffer)],
        type: mimeString
      )
    bb = new BlobBuilder()
    bb.append arrayBuffer
    bb.getBlob mimeString

  if window.HTMLCanvasElement and not CanvasPrototype.toBlob
    if CanvasPrototype.mozGetAsFile
      CanvasPrototype.toBlob = (callback, type, quality) ->
        if quality and CanvasPrototype.toDataURL and dataURLtoBlob
          callback dataURLtoBlob(@toDataURL(type, quality))
        else
          callback @mozGetAsFile("blob", type)
        return
    else if CanvasPrototype.toDataURL and dataURLtoBlob
      CanvasPrototype.toBlob = (callback, type, quality) ->
        callback dataURLtoBlob(@toDataURL(type, quality))
        return
  if typeof define is "function" and define.amd
    define ->
      dataURLtoBlob

  else
    window.dataURLtoBlob = dataURLtoBlob
  return
) this