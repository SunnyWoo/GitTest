# 調整 fixed on bottom 元素的寬度
# position: fixed 的元素如果將 width 設為 100%，他的寬度會跟著螢幕大小，而不是他的 parent，
# 以下的 script 可以修正這個行為，讓它的寬度為父元的寬度
$(document).on 'page:change', ->
  $('.fob').each ->
    $(this).width($(this).parent().width())
