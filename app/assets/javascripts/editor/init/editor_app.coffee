# Public: Initialize editor canvas.
#
# model_background  - editor initial background image
# model_key         - work id
# model_shape       - editor initial layer
#

class @EditorApp
  constructor: ->
    @c = {}

  init: ->
    model_background = $('#drawing').data('modelBackground')
    model_backgroundColor = $('#drawing').data('modelBackgroundColor') or 'transparent'
    model_backgroundColor = 'transparent' if model_backgroundColor == 'none'
    model_key = $('#drawing').data('modelKey')
    model_shape = $('#drawing').data('modelShap')

    switch model_shape
      when 'ellipse'
        $('#drawing').addClass('draw-clock')
      else
        $('#drawing').addClass('draw-cases')

    $('#drawing').width(_modal_w)
    @c = new fabric.Canvas("draw")
    @c.setBackgroundColor model_backgroundColor
    @c.setOverlayImage model_background, @c.renderAll.bind(@c),
      width: _modal_w
      height: _modal_h
    @c.setHeight(_modal_h)
    @c.setWidth(_modal_w)
    @c.selection = false

    @c.renderAll()

  getMainCanvas: ->
    @c

window.editorApp = new EditorApp()
editorApp.init()
