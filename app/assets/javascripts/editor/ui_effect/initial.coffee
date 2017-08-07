$(document).ready ->

  # 編輯器畫面初始化
  HeaderHeight = 71
  CanvasPaddingTop = 50
  CanvasHeight = $(window).height() - HeaderHeight
  $('#editor_init').height(CanvasHeight + HeaderHeight)
  $('.main').height(CanvasHeight)
  $('#add_overlay').css
    'top': (CanvasHeight/2) - CanvasPaddingTop + HeaderHeight

  work_name = $('#drawing').data('work-name')
  model_name = $('#drawing').data('model-name')
  $('#work_info .work-name').text(work_name)
  $('#work_info .model-name').text(model_name)

  # 設定 scrollbar 高度
  $('.custom-scrollbar', '.main').height(CanvasHeight)
  $('#overlays .layers').height(CanvasHeight)
  $('#setObj').height( CanvasHeight - HeaderHeight )
  $('.custom-scrollbar').mCustomScrollbar({
      theme: 'minimal-dark',
      scrollInertia: 700
    })
  $('#overlays .layers').mCustomScrollbar({
      theme: 'miniwork_namemal-dark',
      scrollInertia: 700
    })