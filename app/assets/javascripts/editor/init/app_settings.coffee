# Public: Editor default settings.
# 
# uiConfig   - about editor ui settings
# ctrConfig  - about editor control settings
# default    - other default settings
# 

class @AppSettings
  constructor: ->
    # 物件的 UI 設定
    @uiConfig =
      borderColor:        "#ccc"
      cornerColor:        "#4fbd92"
      cornerSize:         10
      padding:            0
      transparentCorners: false    
    # 移除多餘的控制點
    @ctrConfig =
      mt:  false
      mb:  false
      ml:  false
      mr:  false
      mtr: false
    # 畫布的基本設定
    @default =
      modelHeight: _modal_h
      modelWidth:  _modal_w
      top:         _canvas_y
      left:        _canvas_x
      zoom:        _zoom

  getUiConfig: ->
    @uiConfig

  getCtrConfig: ->
    @ctrConfig

  getDefaultSettings: ->
    @default
