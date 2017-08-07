@_isDebug = false
@_model_w_original = $('#drawing').data('model-width')
@_model_h_original = $('#drawing').data('model-height')
@_modal_w = @_model_w_original
@_modal_h = @_model_h_original
# use percentage
@_maxWidthLimit = 0.6
@_winw = ($(window).width() - 2) * @_maxWidthLimit
@_winh = $(window).height() - 161
@_zoom = 1
@_text_zoom = 0.0745
@_print_zoom = 0.7
@_layerLimit = 10

if @_modal_h > @_winh
  @_zoom = @_winh / @_modal_h
  @_modal_h = @_modal_h * @_zoom
  @_modal_w = @_modal_w * @_zoom

if @_modal_w > @_winw
  @_zoom_2 = @_winw / @_modal_w
  @_zoom = @_zoom * @_zoom_2
  @_modal_h = @_modal_h * @_zoom_2
  @_modal_w = @_modal_w * @_zoom_2
  
maginTop = ( @_winh / 2 ) - ( @_modal_h / 2 ) + 45 + 'px'
$('#drawing').css('margin-top', maginTop)

@_canvas_x = _modal_w / 2
@_canvas_y = _modal_h / 2
