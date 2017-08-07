class @OrderResults
  contstructor: ->
    return

  init: (orders, pages) ->
    @showResults(orders)
    @showPaginations(pages)
    return

  showResults: (orders) ->
    elm = $('#order_results')
    elm.empty()
    for order in orders
      orderNo = order.order_no.order_no
      remoteOrderNo = order.remote_order_no || ''
      orderLink = order.order_no.link
      images = order.images
      status = order.aasm_state
      createAt = order.created_at
      if order.default_currency == 'CNY'
        price = order.render_cny_price
      else
        price = order.render_twd_price
      shipping = order.shipping_way
      country = order.country
      platform = order.platform
      imageTag = ''
      tagsHtml = order.tags.map((tag) => "<label class='label label-success'>#{tag}</label>").join(' ')
      flags = order.flags

      for image in images
        imageTag += '<img class="lazy" data-original="' + image + '"/>'
      row = '<td><a href="' + orderLink + '">' + orderNo + '</a> ' + tagsHtml + '</br><span>' + remoteOrderNo + '</span></td>' + '<td>' + imageTag + '</td>' + '<td>' + status + '</td>' + '<td>'+ flags + '</td>'+ '<td>' + createAt + '</td>' + '<td>' + price + '</td>' + '<td>' + shipping + '</td>' + '<td>' + country + '</td>' + '<td>' + platform + '</td>'
      html = '<tr class="order" id="' + orderNo + '">' + row + '</tr>'
      elm.append(html)
    $('img.lazy').lazyload effect: 'fadeIn'
    return

  showPaginations: (pages) ->
    elm = $('#pagination')
    elm.empty()
    rows = ''
    max = 4
    frontHTML = ''
    frontCount = 0
    backHTML = ''
    backCount = 0
    theFirst = '<li class="click"><a href="javascript:void(0)" data-path="1">1</a></li>'
    theLast = '<li class="click"><a href="javascript:void(0)" data-path="' + pages.total_pages + '">' + pages.total_pages + '</a></li>'
    dotHTML = '<li class="disabled"><a href="javascript:void(0)" >...</a></li>'
    front = pages.current_page - max
    back = pages.current_page + max
    while front < pages.current_page
      if front > 0
        frontHTML += '<li class="click"><a href="javascript:void(0)" data-path="' + front + '">' + front + '</a></li>'
        frontCount++
      front++

    if pages.current_page > max + 1
      rows = theFirst
    if pages.current_page > max + 2
      rows += dotHTML

    rows = rows + frontHTML + '<li class="active"><a href="javascript:void(0)" data-path="' + pages.current_page + '">' + pages.current_page + '</a></li>'

    while back > pages.current_page
      if back < pages.total_pages
        backHTML = '<li class="click"><a href="javascript:void(0)" data-path="' + back + '">' + back + '</a></li>' + backHTML
        backCount++
      back--

    rows = rows + backHTML

    if pages.total_pages - pages.current_page > max + 2
      rows += dotHTML
    if backCount <= max and pages.current_page isnt pages.total_pages
      rows += theLast

    if pages.previous_page or pages.prev_page
      prevOk = 'click'
    else
      prevOk = 'disabled'

    if pages.next_page
      nextOk = 'click'
    else
      nextOk = 'disabled'

    pageInfo = '<li class="' + prevOk + '"><a href="javascript:void(0)" data-path="' + pages.prev_page + '">Prev</a></li>' +
      rows + '<li class="' + nextOk + '"><a href="javascript:void(0)" data-path="' + pages.next_page + '">Next</a></li>'
    html = '<nav><ul class="pagination">' + pageInfo + '</ul></nav>'
    elm.append(html)
    return
