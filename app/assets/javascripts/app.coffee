#= require jquery
#= require turbolinks
#= require plugins/slick
#= require_self

$(document).on 'ready page:load', ->
  $('.kv_images').slick
    autoplay: true
    dots: false
    arrows: false
    draggable: false
    autoplaySpeed: 5000
    speed: 600

  $('.event_block').on 'click', ->
    $(window).scrollTop(0)
    $this = $(this)
    $id = $this.data('id')
    prev_title = $('.app-top').text()
    $('.app-top').data('prev_title', prev_title)
    $('.app-top').text($this.data('title'))
    $('.leftnavs a').addClass('back_event_block').data('id', $id)
    $(".event_page[data-id=#{$id}]").addClass('show')


  $(document).on 'click', '.back_event_block', ->
    $this = $(this)
    $id = $this.data('id')
    prev_title = $('.app-top').data('prev_title')
    $('.app-top').text(prev_title)
    $('.leftnavs a').removeClass('back_event_block').removeData()
    $(".event_page[data-id=#{$id}]").removeClass('show').scrollTop(0)
    return false
