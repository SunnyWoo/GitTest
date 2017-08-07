$(document).on('click touchend', '[data-trigger-show]', (event) ->
  if this == event.target
    $($(this).attr('data-trigger-show')).show()
    return false
)

$(document).on('click touchend', '[data-trigger-hide]', (event) ->
  if this == event.target
    $($(this).attr('data-trigger-hide')).hide()

  if $('.burgerMenu').hasClass('burgerMenu--triggered')
    $('#burgerMenuButton').removeClass('open')
    $('.burgerMenu').removeClass('burgerMenu--triggered')

    return false
)

$(document).on('click', '[data-trigger-toggle]', (event) ->
  if this == event.target
    $($(this).attr('data-trigger-toggle')).toggle()
    return false
)
