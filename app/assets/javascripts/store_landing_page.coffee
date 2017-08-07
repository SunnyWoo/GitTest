#= require jquery
#= require plugins/swiper
#= require ./designer_store/modules/social_share

$(document).on 'ready page:load', ->

  # init swiper
  mySwiper = new Swiper('.store-landing-page-swiper-container', speed: 400)

  # add modal current url
  $('.modal-content-link').html(location.href)

  # show share modal
  $('.btn-share').on 'click', ()->
    $('.modal').addClass('active')

  # cancel share modal
  $('.modal').on 'click', (e)->
    return unless e.target is @

    # e.stopPropagation()
    $('.modal').removeClass('active')

  $('.modal-content-cnacel').on 'click', (e)->
    $('.modal').removeClass('active')

  # back to top
  $('#btn--backToTop').on 'click', ()->
    $('html, body').animate({ scrollTop: 0 }, 300)

  # toggle header menu
  $('.btn--menu').on 'click', ()->
    # $('.header-menu').toggleClass('show-header-menu')

    $hederMenu = $('.header-menu')
    minimumHeight = 0
    currentHeight = $hederMenu.innerHeight()
    autoHeight = $hederMenu.css('height', 'auto').innerHeight()
    console.log 'currentHeight', currentHeight
    console.log 'autoHeight', autoHeight
    if currentHeight == minimumHeight
      $hederMenu.animate({
        height: autoHeight
      })
    else
      $hederMenu.animate({
        height: minimumHeight
      })

  #init sharing functionality
  share = new SocialShare(
    image: 'http://www.planwallpaper.com/static/images/wallpapers-hd-8000-8331-hd-wallpapers.jpg'
    title: '我印頁店'
  )

  $('#share-btn--fb').click ->
    share.share('facebook')

  $('#share-btn--twitter').click ->
    share.share('twitter')

  $('#share-btn--line').click ->
    share.share('line')
