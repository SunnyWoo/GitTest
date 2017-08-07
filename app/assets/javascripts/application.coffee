#= require rollbar-shim
#= require jquery
#= require jquery_ujs
#= require jquery.extend
#= require jquery-ui/effect-blind
#= require plugins/jquery.timers
#= require plugins/slick
#= require plugins/bootstrap-dropdown
#= require plugins/lodash.min
#= require fancybox
#= require jquery.carouFredSel-6.2.1
#= require plugins/macho
#= require plugins/jquery.scrollTo.min
#= require plugins/jquery.ui.widget
#= require plugins/jquery.fileupload
#= require plugins/jquery.innerfade
#= require plugins/bootstrap-modal
#= require plugins/moment
#= require plugins/jquery.jeditable
#= require jquery.tooltipster.min
#= require common/innerfade
#= require common/form_timeout
#= require common/locale
#= require common/youtube
#= require common/lazyload
#= require common/magnific_init
#= require commandp
#= require editor/countdown
#= require editor/auto_modal
#= require editor/preview
#= require cart
#= require redeem
#= require search
#= require facebook
#= require career
#= require underscore
#= require json2
#= require judge
#= require users
#= require auto_submit
#= require rails_env_favicon
#= require support
#= require shopping_cart
#= require going_payment
#= require social
#= require works
#= require default_product
#= require_self
#= require turbolinks
#= require payment/stripe
#= require payment/pingpp_alipay_qr
#= require_tree ./web
#= require_tree ./campaign
#= require appier/appier_retarget

window.App =

  init: () ->
    $.extend $.expr[':'],
      myContains: (elem, i, match, array) ->
        (elem.textContent or elem.innerText or '').toLowerCase().indexOf((match[3] or '').toLowerCase()) >= 0

    $(document).on 'keyup', '#search', ->
      $('#article .lists li').removeHighlight()
      key = $(this).val().toLowerCase()
      if key
        unmatch = $('#article .lists li:not(:myContains(' + key + '))')
        match = $('#article .lists li:myContains(' + key + ')')
        unmatch.css display: 'none'
        match.css(display: '').highlight key
        match.children('.content').removeClass('hide')
        match.children('.arti-header').css(
          color: '#455055'
          'font-weight': '400'
        ).children('i').removeClass('icons-faq_open').addClass('icons-faq_close')
      else
        arti = $('.arti-header')
        $('.content').addClass('hide')
        $('.lists li').attr('style', '')
        arti.attr('style','')
        arti.find('i').removeClass('icons-faq_close').addClass('icons-faq_open')
      return

    toggle_click = []

    $(document).on 'click', '.questions .arti-header', ->
      index = $('.arti-header').index($(this))
      elm = $(this).next('.content')
      unless toggle_click[index]
        elm.removeClass 'hide'
        $(this).css
          color: '#455055'
          'font-weight': '400'

        $(this).children().removeClass('icons-faq_open').addClass 'icons-faq_close'
        toggle_click[index] = true
      else
        elm.addClass 'hide'
        $(this).css
          color: ''
          'font-weight': ''

        $(this).children().removeClass('icons-faq_close').addClass 'icons-faq_open'
        toggle_click[index] = false
      return

    $(document).on 'click','li[role=item_qty]', '.dropdown', ->
      val = $(this).find('div').data('value')
      $(this).parent().parent().find('span.val').text(val);
      if $( "a.add_to_cart").length > 0
        url = $( "a.add_to_cart").attr('href').replace(/(\?.*)+/,'')
        $( "a.add_to_cart").attr('href', "#{url}?q=#{val}")
      return

    $('p').macho({ 'length' : 6 })

    # career page
    $(document).on 'click', '.scroll-to', ->
      top_height = 1038
      target = parseInt($(this).attr('data-scto'), 10)
      top = $('h2.item-title').eq(target).position().top - 30
      $.scrollTo(top, 600)
      return

    $(document).on 'click', '.thumb-list li', ->
      unless $(this).hasClass('show-on')
        target = $(this).attr('data-thumb')
        $('img', '.show-box').addClass('hide').removeClass('fadeIn')
        $('img[data-img=' + target + ']', '.show-box').removeClass('hide').addClass('fadeIn')
        $('.thumb-list li').removeClass('show-on')
        $(this).addClass('show-on')

    # $('.case-preview .cover').append('<img src="' + $('#preview_data').data('front-cover') + '" >')
    if $('.works.preview').size() > 0 and _.size(localStorage.getItem('cmdp_editor_coverImage')) > 0
      setPreview()

    return

$(document).ready ->
  App.init()
  return

$(document).on 'ready page:load', ->
  $('.q-size').each ->
    length = $(this).text().length
    num = parseInt($(this).text().slice(1, length-1), 10)
    if(num <= 0)
      $(this).parent().addClass('hide')
    return

  if $("#banner").length > 0
    $("#banner").carouFredSel
      items: 3
      responsive: false
      width: 1100
      height: 366

  # old slider
  # -------------------------------
  # $('.owl-carousel').owlCarousel
  #   singleItem: true
  #   nav: true
  #   autoWidth:true
  #   loop: true
  #   autoplay: true
  #   autoplayTimeout: 6000
  #   smartSpeed: 1000
  #   lazyLoad: true
  $('.owl-carousel').slick
    autoplay: true
    dots: true
    draggable: false
    autoplaySpeed: 8000
    speed: 600

  $('.header .profile-btn').hover ->
    offset = $(this).position()
    $('.profile_dropdown').removeClass('hide').css({
      'top': offset.top + 25 + 'px',
      'left': offset.left + 'px'
      })
    return
  , ->
    $('.profile_dropdown').addClass('hide')
    return

  $(document).scroll ->
    scroll_now = $(this).scrollTop();
    if(scroll_now >= 420)
      offset = $('.check_out #check_out_summery').position()
      summary_height = $('.check_out #check_out_summery').height()
      if offset?
        $('.check_out #check_out_summery').css({
          'position': 'fixed',
          'top': '30px',
          'left': offset.left + 'px'
          })
        if(scroll_now >= $(this).height() - ( 650 + summary_height ))
          fixed_position = -(scroll_now - ($(this).height() - ( 650 + summary_height ))) + 30
          $('.check_out #check_out_summery').css({
            'top': fixed_position + 'px',
            'left': offset.left + 'px'
            })
    else
      $('.check_out #check_out_summery').attr('style', '')
    return

  $('#mask').hover ->
    $('#edit').removeClass('hide')
    return
  , ->
    $('#edit').addClass('hide')
    return

  $('#atm_popup').on 'click', ->
    $('#atm_notice').modal({ show: true })
    return

  $('#mmk_popup').on 'click', ->
    $('#mmk_notice').modal({ show: true })
    return

  $(document).on 'click', '#login_popup', ->
    $('#login_notice').modal({ show: true })
    return false

  $('.link-detail').on 'click', ->
    $('#announcement_detail').modal({ show: true })
    return

  $(".modal").each ->
    $(this).show()  if $(this).hasClass("in") is false # Need this to get modal dimensions
    contentHeight = $(window).height() - 101
    headerHeight = $(this).find(".modal-header").outerHeight() or 2
    footerHeight = $(this).find(".modal-footer").outerHeight() or 2
    $(this).find(".modal-content").css "max-height": contentHeight

    $(this).find(".modal-body").css "max-height": contentHeight - (headerHeight + footerHeight + 30), "overflow-y": 'auto'
    $(this).find(".modal-dialog").addClass("modal-dialog-center").css
      "margin-top": ->
        -($(this).outerHeight() / 2)

      "margin-left": ->
        -($(this).outerWidth() / 2)

    $(this).hide()  if $(this).hasClass("in") is false # Hide modal
    return

  return

setPreview = ->

  @sendCoverImage()

  return
