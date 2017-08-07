#= require plugins/jquery.lazyload

jQuery ($) ->

  cart = []
  window.cart = cart;
  processing = {};


  showCart = ->
    $('.mobilev2 #cart-isnot-empty .cart-item-block').remove();
    $('.mobilev2 #cart-subtotal').text(cart.subtotal)
    for item in cart.order_items
      nblock = $('#cartdemoblock').clone();
      $('#image', nblock).attr('src', item.order_image_thumb)
      $('#qty', nblock).val(item.quantity)
      $('#model', nblock).text(item.model_name)
      $('#title', nblock).text(item.name)
      $('#price', nblock).text(item.subtotal)
      $('.mobilev2 #cart-isnot-empty .mobilev2-content').prepend(nblock)
      nblock[0].id = item.uuid
      nblock[0].cart = item

    if cart.order_items.length
      $('.mobilev2 #cart-isnot-empty').removeClass('hide').fadeIn()
    else
      $('.mobilev2 #cart-is-empty').fadeIn()


  refreshAddress = (cart) ->
    cart = cart || window.cart
    address = cart.shipping_info
    $('.mobilev2 #truename input').val(address.name) if  address.name
    $('.mobilev2 #address1 input').val(address.address) if  address.address
    $('.mobilev2 #city input').val(address.city) if  address.city
    $('.mobilev2 #phone input').val(address.phone) if  address.phone
    $(".mobilev2 #state select option[value=#{address.country_code}]")[0]?.selected = true if address.country_code
    $('.mobilev2 #zipcode input').val(address.zip_code) if  address.zip_code
    $('.mobilev2 #email input').val(address.email) if  address.email


  refreshSummary = (cart) ->
    cart = cart || window.cart
    $('.mobilev2 #subtotal').text(cart.subtotal)
    $('.mobilev2 #grandtotal').text(cart.price)
    $('.mobilev2 #discount').text("- "+cart.discount)
    $('.mobilev2 #shipping_fee').text(cart.shipping_fee)

  refreshCoupon = (cart) ->
    cart = cart || window.cart
    if cart.coupon_code
      return unless $('#coupon_code').length
      $('.mobilev2 #coupon_code').val(cart.coupon_code)[0].disabled = true
    else
      return unless $('#coupon_code').length
      # $('.mobilev2 #coupon_code').val('')[0]?.disabled = false

  refreshPaymentAndShipping = (cart) ->
    cart = cart || window.cart
    $(".mobilev2 .payment-radio-box[value='#{cart.payment}']")[0]?.checked = true
    $(".mobilev2 .shipping-radio-box[value=#{cart.shipping_info_shipping_way}]")[0]?.checked = true

    if cart.shipping_info_shipping_way == "cash_on_delivery"
      $('.mobilev2 .show-cod').slideDown()
      $('.mobilev2 .not-show-cod').slideUp()
      $('.mobilev2 #is_cash_on_deliviry').text('Yes')
    else
      $('.mobilev2 .not-show-cod').slideDown()
      $('.mobilev2 .show-cod').slideUp()
      $('.mobilev2 #is_cash_on_deliviry').text('No')

  refreshCart = (cart) ->
    cart = cart || window.cart
    $('.mobilev2 #cart-count').text(cart.order_item_quantity_total)
    prodsInCart = {}
    for item in cart.order_items
      prodsInCart[item.uuid] = item

    $('.mobilev2 #cart-is-empty').fadeOut()
    $('.mobilev2 #cart-isnot-empty').fadeOut(showCart)
    $prods = $('.btn-mobile-cart')
    processing = {};
    for prod in $prods
      if prodsInCart[prod.id]
        $(prod).addClass('mobile-cart-activated').text($(prod).data('mobileaddedtext'))
      else
        $(prod).removeClass('mobile-cart-activated').text($(prod).data('mobileaddtext'))

  # only path at /cart
  autoShowCart = () ->
    if !!location.pathname.match(/[a-z-]+\/cart/i) && !$('#cart-popup').attr('style')?
      $('.cart-popup-open').click()

  refreshAll = (cart) ->
    cart = cart || window.cart
    refreshCart(cart)
    refreshCoupon(cart)
    refreshAddress(cart)
    refreshPaymentAndShipping(cart)
    refreshSummary(cart)
    autoShowCart()
    check_cash_on_delivery($('.mobilev2 form#address-form #state select').val())

  refreshPaymentAndShippingAndSummary = (cart)->
    refreshPaymentAndShipping(cart)
    refreshSummary(cart)

  showCartPrice = (cart) ->
    $('.mobilev2 #cart-subtotal').text(cart.subtotal)
    $('.mobilev2 #cart-count').text(cart.order_item_quantity_total)
    $cart_pop = $('.mobilev2 #cart-popup')
    for item in cart.order_items
      $("##{item.uuid} #price", $cart_pop).text(item.subtotal)
    refreshSummary(cart)

  hideCartPrice = (item)->
    $('.mobilev2 #cart-subtotal').text('Loading...')
    $('#price', item.parents('.cart-item-block')).text('Loading...') if item

  window.mobileV2Reload =  (callback) ->
    callback = refreshAll if typeof callback != 'function'
    $.ajax({
      type:'GET',
      dataType:'json',
      cache: false,
      url:"/#{getLocale()}/cart.json",
      success: (data, textStatus, jqXHR) ->
        cart = data.cart
        window.cart = cart;
        callback(cart);
    })

  window.mobileV2RemoveItem = (i) ->
    return  unless cart.order_items[i]
    item = cart.order_items[i]
    $.ajax({
      type: 'DELETE',
      url:item.del_path,
      success: (data, textStatus, jqXHR) ->
        cart.order_items.splice(i,1)
    })

  verifyCoupon = () ->
    return if $('.mobilev2 #coupon_code')[0].disabled
    $('.mobilev2 #coupon_ok').addClass('hide')
    $('.mobilev2 #coupon_bad').addClass('hide')
    $submit = $('.mobilev2 .coupon-submit')

    $submit.data('originbg', $submit.css('background-image'))

    $submit.css('background-image', "url(#{$submit.data('waitingbg')})")

    $.ajax
      url: "/#{getLocale()}/cart/coupon.json",
      type: 'post',
      data: { coupon_code: $('.mobilev2 #coupon_code').val() },

      success: (data) ->
        if data.status == 0
          $('.mobilev2 #coupon_ok').removeClass('hide');
          $('.mobilev2 #coupon_code')[0].disabled = true;
        else
          $('.mobilev2 #coupon_bad').removeClass('hide');
        mobileV2Reload(refreshSummary)

      complete: (data) ->
        $('.mobilev2 .coupon-submit').css('background-image', '')

  validateAddress =  (addressForm)->
    addressForm = addressForm || $('#address-form')
    isOk = true

    if !!getLocale().match(/zh/)
      required_text = '*必填'
    else
      required_text = '*required'

    if !!getLocale().match(/zh/)
      invalid_email_text = '*必須為正確的email格式'
    else
      invalid_email_text = '*E-mail is in invalid format'

    target = $('#truename input', addressForm)
    val = target.val()
    unless val && val.length
      isOk = false
      $('.form-control-warn', target.parent()).text(required_text)


    target = $('#email input', addressForm)
    val = target.val()
    unless val && val.length&& val.match(/[^\s]+@[^\s]+\.[a-zA-Z]+$/)
      isOk = false
      $('.form-control-warn', target.parent()).text(invalid_email_text)

    target = $('#address1 input', addressForm)
    val = target.val()
    unless val && val.length
      isOk = false
      $('.form-control-warn', target.parent()).text(required_text)

    if $('#city input').length > 0
      target = $('#city input', addressForm)
      val = target.val()
      unless val && val.length
        isOk = false
        $('.form-control-warn', target.parent()).text(required_text)

    target = $('#zipcode input', addressForm)
    val = target.val()
    unless val && val.length
      isOk = false
      $('.form-control-warn', target.parent()).text(required_text)

    target = $('#phone input', addressForm)
    val = target.val()
    unless val && val.length
      isOk = false
      $('.form-control-warn', target.parent()).text(required_text)

    return isOk

  newPageWButton = (content) ->
    np = $('<div class="page"></div>')
    np.append($('<div class="page-content"></div>').append(content))
    np.append('<div class="page-button">下一頁</div> ')
    return np

  generatePageNest = (dom) ->
    dom = $(dom)
    tohide = $('.product:gt(5)', dom)
    return unless tohide.length
    dom.append(newPageWButton(tohide))
    generatePageNest($('.page-content', dom))

  check_cash_on_delivery = (val) ->
    if val == 'TW'
      $('.mobilev2 .form-group#payment_cash_on_delivery').removeClass('hide')
    else
      $('.mobilev2 .form-group#payment_cash_on_delivery').addClass('hide')
      $(".mobilev2 .payment-radio-box")[0]?.checked = true if cart.payment == 'cash_on_delivery'


  $(document).on 'ready page:load', ->
    # image lazyload
    return unless $('.mobilev2').length > 0

    $("img").lazyload(effect: 'fadeIn')

    # pager
    $('.mobilev2 .filted').each((i,dom)-> generatePageNest(dom))
    $('.mobilev2 .page-button').on 'touchend click', ->
      $('.page-content:first', $(this).hide().parent()).show()


    # bind cart item del and qty change event
    $('.mobilev2 .mobilev2-content').on 'click touchend', '.cart-item-del-text', ->
      dom = $(this).parents('.cart-item-block')
      $.ajax({
        type: 'DELETE',
        url:dom[0].cart.del_path,
        success: (data, textStatus, jqXHR) ->
          mobileV2Reload()
        error: (jqXHR, textStatus, errorThrown) ->
          mobileV2Reload()
      })
      dom.slideUp(-> dom.remove())

    $('.mobilev2 .mobilev2-content').on 'change', '.cart-item-qty-value', ->
      dom = $(this)
      hideCartPrice(dom)
      $.ajax
        url:"/#{getLocale()}/cart/#{this.parentNode.parentNode.id}.js",
        type: "put",
        data: { q: dom.val() },
        success: ->
          mobileV2Reload(showCartPrice)

    $('.mobilev2 .mobilev2-content').on 'change', '.cart-item-qty-value-ios', ->
      dom = $(this)
      hideCartPrice(dom)
      $.ajax
        url:"/#{getLocale()}/cart/#{this.parentNode.parentNode.id}.js",
        type: "put",
        data: { q: dom.val() },
        success: ->
          mobileV2Reload(showCartPrice)

    # $('.product').each ->
    #   prod = $(this)
    #   return unless cate_key = prod.data('category-key')
    #   $('category-#{')
    $('.mobilev2 .category-select:not(#m-campaign-select)').on 'change', ->
      dom = $(this)
      $('.mobilev2 .filted').fadeOut ->
        setTimeout( ->
          $('#'+dom.val()).fadeIn 500, ->
            document.body.scrollTop++
            document.body.scrollTop--
        ,100)
      ga "send", "event", dom.data('category'), "Select Model", dom.val()


    $('.mobilev2 .category-select-ios:not(#m-campaign-select)').on 'change', ->
      dom = $(this)
      category = dom.data('category')
      $('.mobilev2 .filted').fadeOut ->
        setTimeout( ->
          $('#'+dom.val()).fadeIn 500, ->
            document.body.scrollTop++
            document.body.scrollTop--
        ,100)
      ga "send", "event", dom.data('category'), "Select Model", dom.val()

    $('#'+$('.category-select:not(#m-campaign-select)').val()).fadeIn(500)
    $('#'+$('.category-select-ios:not(#m-campaign-select)').val()).fadeIn(500)

    $('.mobilev2 .btn-mobile-cart').on 'click', ->
      dom = $(this)
      return if processing[this]
      processing[this] = true;
      WorkName = dom.data('work')
      ModelName = dom.data('model')

      if dom.hasClass(dom.data('mobiletoggle'))
        $.ajax({
          type: 'DELETE',
          url:dom.data('mobiledelpath'),
          dataType: 'json',
          success: (data, textStatus, jqXHR) ->
            mobileV2Reload()
          error: (jqXHR, textStatus, errorThrown) ->
            mobileV2Reload()
        })
        ga "send", "event", dom.data('category'), "Remove from Cart", "#{WorkName} - #{ModelName}"
        dom.text(dom.data('mobileremovingtext'))
      else
        $.ajax({
          type: 'PUT',
          url:dom.data('mobileaddpath'),
          dataType: 'json',
          success: (data, textStatus, jqXHR) ->
            mobileV2Reload()
          error: (jqXHR, textStatus, errorThrown) ->
            mobileV2Reload()
        })
        ga "send", "event", dom.data('category'), "Add to Cart", "#{WorkName} - #{ModelName}"
        dom.text(dom.data('mobileaddingtext'))

     $('.mobilev2 #country_code').on 'change', ->
        $.ajax
          async: false
          url: "/#{getLocale()}/cart/check_out_update.js",
          type: 'patch',
          data: { attr: 'country_code' , val: this.value },
          success: ->
            mobileV2Reload(refreshPaymentAndShippingAndSummary)

     $('.mobilev2 .payment-radio-box').on 'click', ->
        payment_label = $(this).parents('label').find('span:first').text()
        $.ajax
          url: "/#{getLocale()}/cart/check_out_update.js",
          type: 'patch',
          data: { attr: 'payment' , val: this.value },
          success: ->
            mobileV2Reload(refreshPaymentAndShippingAndSummary)
            $('.mobilev2 #checkout_but').text("Pay with #{payment_label}")

     $('.mobilev2 .not-show-cod input').on 'click', ->
        $.ajax
          url: "/#{getLocale()}/cart/check_out_update.js",
          type: 'patch',
          data: { attr: 'shipping_way' , val: this.value },
          success: ->
            mobileV2Reload(refreshPaymentAndShippingAndSummary)

      $('.mobilev2 .coupon-submit').on 'click touchend', ->
        verifyCoupon();

      $('.mobilev2 form#address-form #state select').on 'change', ->
        check_cash_on_delivery(this.value)
    #-------------------------------------------------
    # address form disable warning
    $('.mobilev2 #address-form').on 'focus click touchend', '.form-group', ->
      $('.form-control-warn', this).text('')

    isProccessing = false
    $('.mobilev2 #checkout_but').on 'click touchend', ->
      return $('body').scrollTo(0, 500) unless validateAddress()

      address =
        name: $('.mobilev2 #truename input').val(),
        address: $('.mobilev2 #address1 input').val(),
        city: $('.mobilev2 #city input').val(),
        phone: $('.mobilev2 #phone input').val(),
        country_code: $('.mobilev2 #state select').val(),
        zip_code: $('.mobilev2 #zipcode input').val(),
        email: $('.mobilev2 #email input').val(),
      address.address_name = address.zip_code+address.name+address.address+address.city+address.country_code
      return if isProccessing
      isProccessing = true
      $(this).text('Loading...')
      $.ajax
        async: false
        url: "/#{getLocale()}/cart/check_out_update.js",
        type: 'patch',
        data: { attr: 'billing_info' , val: address }

      $.ajax
        async: false
        url: "/#{getLocale()}/cart/check_out_update.js",
        type: 'patch',
        data: { attr: 'shipping_info' , val: address }

      mobileV2Reload((data) ->
        # if cart.payment == 'stripe'
        #   $(".card-popup-open").click()

        # else
          link = $("<a data-method='post' href='#{cart.payment_path}'></a>")
          $(document.body).append(link)
          link.click()
      )
      isProccessing = false

    $('.mobilev2 .mobile-v2-fb-btn').on 'click touch', ->
      FB.ui
        picture: $(this).data('facebookImage')
        method: 'feed'
        display: 'touch'
        link: $(this).data('facebookLink')
        caption: $(this).data('facebookCaption')
      ,()->
    # ------------------------------------------------
    # generate #id-open #id-close for each #id.popups

    stopPropagation = (e) ->
      e.stopPropagation()

    OpenedPopusCount = 0;
    hideTO = 0;
    scrollTop = 0

    viewStacks = [[$('.main-container'),0]];

    open = (dom) ->
      dom.style.left = '0px'
      $(dom).find('input, select').removeAttr('disabled')
      coupon_input = $(dom).find('input[name=coupon]')
      coupon_input.attr('disabled', 'disabled') if coupon_input.val() != ''
      OpenedPopusCount++
      # document.body.style.overflow = 'hidden'
      # $(document.body).on 'touchstart', stopPropagation
      target = viewStacks[0]
      $('.fixed').hide()
      hideTO = setTimeout(->
        target.push(dom.style.position)
        target[0].hide()
        dom.style.position = 'relative'
      , 300)
      target[1] = target[0].parent().scrollTop()
      viewStacks.splice(0, 0, [$(dom),0])

    close = (dom) ->
      clearTimeout(hideTO)
      dom.style.position = 'fixed'
      dom.style.left = '120%'
      $(dom).find('input, select').attr('disabled', 'disabled')
      viewStacks.splice(0, 1)
      if viewStacks.length == 1
        $('.fixed').show()
      target = viewStacks[0]
      target[0].show()
      target[0].parent().scrollTop(target[1])


    $('.mobilev2 .popups').each () ->
      me = this
      $('.' + me.id + '-open').on 'touch click', ->
        open(me)
      $('.' + me.id + '-close').on 'touch click', ->
        close(me)

    $('.mobilev2 .tab-opener').each () ->
      if targetids = $(this).data('targetids')
        targetids = targetids.split(',')
        for id in targetids
          open($('#'+id)[0])


    mobileV2Reload()

campaignCheckUrl = (hash = '')->
  if $('.campaign-page').length > 0
    hash = '#info' if hash == ""
    if window.location.pathname.match(/denka/i) && hash == '#info'
      $('#m-denka-select').addClass('m-denka-select-block')
    else
      $('#m-denka-select').removeClass('m-denka-select-block')
    $(".campaign-page").hide()
    $(".campaign-page#{hash}_page").show()
    $('.campaign-nav li.active').removeClass('active')
    $("a[href=#{hash}]").parent().addClass('active')
    if $('select#m-campaign-select').length > 0
      $('select#m-campaign-select').val(hash.replace('#',''))

window.campaignCheckUrl = campaignCheckUrl

$(document).on 'ready page:load', ->
  campaignCheckUrl(window.location.hash)
  $('.campaign-nav a, .campaign_change_page').on 'click', () ->
    $('html, body').animate({ scrollTop: $('.campaign-nav').offset().top }, 500);
    campaignCheckUrl($(this).attr('href'))

  $('select#m-campaign-select').on 'change', () ->
    hash = "##{$(this).val()}"
    campaignCheckUrl(hash)
    window.location.hash = hash

  $('.kv-button-shop-now').on 'click', ()->
    $this = $(this)
    campaignCheckUrl($this.attr('href'))

  if location.pathname.match(/merryxmas/) && location.search.match(/photo_page/)
    $('html, body').animate({ scrollTop: $('#xmax_photos').offset().top }, 500)

  $('#nyresolution-see-more').on 'click', ()->
    $('#info_page .hide').removeClass('hide')
    $(this).hide()

