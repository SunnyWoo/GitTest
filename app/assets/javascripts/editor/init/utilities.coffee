Array::remove = (value) ->
  idx = @indexOf(value)
  return @splice(idx, 1)  unless idx is -1
  false

Array::move = (old_index, new_index) ->
  if new_index >= @length
    k = new_index - @length
    @push 'undefined'  while (k--) + 1
  @splice new_index, 0, @splice(old_index, 1)[0]
  this # for testing purposes

fabric.Canvas::getItemByKey = (key) ->
  object = null
  objects = @getObjects()
  i = 0
  len = @size()

  while i < len
    if objects[i].hash_key and objects[i].hash_key is key
      object = objects[i]
      break
    i++
  [object, i]

# add 'X-Request-ID' into all request header
$.ajaxSetup
    beforeSend: (xhr) ->
        xhr.setRequestHeader('X-Request-ID', makeHashKey())

makeHashKey = ->
  d = new Date().getTime()
  key = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx".replace(/[xy]/g, (c) ->
    r = (d + Math.random() * 16) % 16 | 0
    d = Math.floor(d / 16)
    ((if c is "x" then r else (r & 0x7 | 0x8))).toString 16)
  key