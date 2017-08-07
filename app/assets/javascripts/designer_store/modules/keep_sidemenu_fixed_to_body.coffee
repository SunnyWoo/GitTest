# 因為 fixed 是跟隨螢幕寬度，但 sidemenu 要跟隨 body 的邊界，
# 所以只好用 JavaScript 修正
$(document).on 'page:change', ->
  $sidemenu = $('[data-fixed-bottom-right]')
  $sidemenu.css right: $('body').offset().left
