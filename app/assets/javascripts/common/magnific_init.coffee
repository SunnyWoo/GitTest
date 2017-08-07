#= require magnific-popup

$(document).on 'page:change',  ->
  $('.popup-image').magnificPopup
    type: 'image'

  $('.popup-gallery').each () ->
    $(this).magnificPopup
      delegate: 'a'
      type: 'image'
      gallery:
        enabled:true
        tCounter: ''
