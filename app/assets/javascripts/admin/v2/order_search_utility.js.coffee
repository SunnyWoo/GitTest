@filtersInit = ->
  url = $('.widget-main').data('path')

  data = $.Deferred ->
    ajax = $.ajax
      url: url
      type: 'GET'
      dataType: 'json'

    ajax.done (response) ->
      data.resolve(response)

  data.promise()

@getUrlVars = ->
  vars = []
  hash = undefined
  hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&')
  i = 0
  while i < hashes.length
    hash = hashes[i].split('=')
    vars.push hash[0]
    vars[hash[0]] = hash[1]
    i++
  vars

@searchResult = (searchInput='', sort='created_at desc', page=1)->

  options =
    aasm_state: ''
    payment: ''
    billing_info_country_code: ''
    platform: ''
    work_states: ''
    created_at: ''
    coupon: ''
    flags: ''

  for option in CmdpAdmin.options
    switch option.platform
      when 'aasm_state'
        if options.aasm_state is ''
          options.aasm_state = option.value
        else
          options.aasm_state += ',' + option.value
      when 'payment'
        if options.payment is ''
          options.payment = option.value
        else
          options.payment += ',' + option.value
      when 'billing_info_country_code'
        if options.billing_info_country_code is ''
          options.billing_info_country_code = option.value
        else
          options.billing_info_country_code += ',' + option.value
      when 'platform'
        if options.platform is ''
          options.platform = option.value
        else
          options.platform += ',' + option.value
      when 'work_states'
        if options.work_states is ''
          options.work_states = option.value
        else
          options.work_states += ',' + option.value
      when 'created_at'
        options.created_at = option.value
      when 'coupon'
        options.coupon = option.value
      when 'flags'
        if options.flags is ''
          options.flags = option.value
        else
          options.flags += ',' + option.value
        # CmdpAdmin.options = []

  url = $('.widget-main').data('queryPath')

  if url?
    ajax = $.ajax
      url: url
      type: 'GET'
      dataType: 'json'
      data:
        order_search:
          search: searchInput
          aasm_state: options.aasm_state
          payment: options.payment
          billing_info_country_code: options.billing_info_country_code
          platform: options.platform
          work_states: options.work_states
          created_at: options.created_at
          coupon: options.coupon
          flags: options.flags
          s: sort
        page: page

    ajax.done (response)->
      $('#order_search').attr("disabled", false)
      show = new OrderResults
      show.init(response.orders, response.meta.pagination)

window._orderSort = 'created_at desc'

$(document).on 'click', '#order_search', ->
  elm = $(this)
  elm.attr("disabled","disabled")
  $.fancybox.showLoading()
  input = $('#order_input').val()

  searchResult(input, _orderSort)

$(document).on 'click', '.sort', ->
  elm = $(this)
  $.fancybox.showLoading()
  sortTag = elm.data('sort')
  sortID = elm.data('id')
  input = $('#order_input').val()

  $('.sort').each ->
    $(this).children('span').remove()

  if sortTag is 'asc'
    sortTag = 'desc'
    elm.append('<span> &#8711;</span>')
  else if sortTag is 'desc'
    sortTag = 'asc'
    elm.append('<span> &#916;</span>')
  else
    sortTag = 'asc'
    elm.append('<span> &#916;</span>')

  elm.data('sort', sortTag)
  sort = sortID + ' ' + sortTag
  window._orderSort = sort
  searchResult(input, sort)

$(document).on 'click', '#pagination li.click', ->
  elm = $(this)
  $(document).scrollTop(0)
  $.fancybox.showLoading()
  input = $('#order_input').val()
  page = elm.children('a').data('path')
  searchResult(input, _orderSort, page)

$(document).on 'ready page:load', ->
  $('.sort').each ->
    elm = $(this)
    if elm.data('sort') is 'asc'
      elm.append('<span> &#916;</span>')
    else if elm.data('sort') is 'desc'
      elm.append('<span> &#8711;</span>')
  searchParam = getUrlVars()
  if searchParam.search
    text = decodeURIComponent searchParam.search
    CmdpAdmin.options = []
    $('#order_input').val(text)
    searchResult(text)
  else if searchParam.coupon
    value = decodeURIComponent searchParam.coupon
    CmdpAdmin.options = [{
      platformName: 'Coupon',
      valueName: value,
      platform: 'coupon',
      value: value}]
    searchResult()
  else
    searchResult()
  return
