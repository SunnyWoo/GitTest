# for ImageHelper#image_webp

$(document).on 'page:change', ->
  Modernizr.on 'webp', ({ lossless }) ->
    $('img[data-use-image-webp]').each (index, img) ->
      $img = $(img)
      imgSrc = if lossless
          $img.data 'imgWebp'
        else
          $img.data 'imgOriginal'
      $img.attr 'src', imgSrc
      $img.removeAttr 'data-use-image-webp'
