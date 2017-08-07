
launch = (column) ->
  rows = $('.kv-denka-row', column)
  rows.first().addClass('active')
  setInterval((-> rotate(column)), 4000)

rotate = (column) ->
  last = $('.active', column)
  return unless last.length
  next = last.next()
  next = last.siblings().first() unless next.length
  last.addClass('closing')
  setTimeout((-> last.removeClass('active').removeClass('closing')), 1000)
  next.addClass('active')

$(document).on 'ready page:load', ->
  timeDiff = 0;

  $('.kv-denka-column').each (e) ->
    rows = $('.kv-denka-row', this)
    unless rows.length > 1
      rows.addClass('deactive')
      return
    column = this
    setTimeout((-> launch(column)), timeDiff)
    timeDiff += 2000

  $('.campaign-inpage-nav-item', '.campaign-inpage-nav').click (e) ->
    targetId = $(this).data('target')
    $('html, body').animate(scrollTop: $("##{targetId}").offset().top, 500)

  $(window).scroll () ->
    if $(this).scrollTop() > 1400
      $('#back_top').fadeIn()
    else
      $('#back_top').fadeOut()

  $('#back_top').click (e) ->
    $('html, body').animate({ scrollTop: 0 }, 500);
