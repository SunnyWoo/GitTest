$(document).on 'page:change', ->
  return if $('body.orders_controller.search_action').length == 0

  # clear search form input
  clearInput = () ->
    $('#orders-search-form').find('input:not([type=submit])').attr('value', '')

  # return to search form section when user is on search result success state
  $(document).on 'click', '#button--queryOtherOrder', () ->
    $('#order-search-result').hide()
    $('#order-search-form-section').show()
    clearInput()

  # return to search form section when user is on search result failure state
  $('.button--orderSearchFailure').on 'click', ->
    $('#search-mask').hide()

  $('#orders-search-form').on 'ajax:error', (e, xhr, status, error) ->
    $('#search-mask').show()

  $('#orders-search-form').on 'submit', () ->
    values = (obj.value for obj in $('#orders-search-form').find('input[name*=order]'))
    if values.join('') == ''
      $('#search-mask').show()
      return false
