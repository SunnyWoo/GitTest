$(document).on 'page:change', ->
  return if $('body.works_controller.preview_action').length == 0

  initialCarousel = ->
    $('[data-widget-slick]').not('.slick-initialized').slick
      dots: true,
      arrows: false

  fetchPreviewImage = () ->
    $.ajax "/api/works/#{jsPageData.data.workUuid}/previews",
      headers:
        Accept: 'application/vnd.commandp.v3+json'
        Authorization: "Bearer #{jsPageData.data.accessToken}"
      success: (data) ->
        # response successful Test Data
        #
        # data = {
        #   work: {
        #     ready: true,
        #     previews: [
        #       {
        #         normal: 'http://placehold.it/900/304c85',
        #       },
        #       {
        #         normal: 'http://placehold.it/900/f5e5a3',
        #       },
        #       {
        #         normal: 'http://placehold.it/900/4e909c/fbc900',
        #       }
        #     ]
        #   }
        # }

        if data.work.ready
          data.work.previews.forEach (preview) ->
            $('[data-widget-slick]').append( ->
              imageSize = $(this).width()

              $("<img class='cover-image' src='#{preview.normal}'>")
                .width(imageSize).height(imageSize)
            )

          clearInterval(pollingPreviewImageInterval)
          initialCarousel()

  if $('[data-widget-slick]').find('img').length == 0
    pollingPreviewImageInterval = setInterval(fetchPreviewImage, 3000)
  else
    initialCarousel()

  $('.calculator-item--minus').hide()

  $('.calculator-item--plus').on 'click', () ->
    $result = $('.calculator-item--result')
    $minus = $('.calculator-item--minus')
    $minusShadow = $('.calculator-item--minusShadow')

    amountNum = +$result.text()

    $minus.show()
    $minusShadow.hide()
    $result.text(amountNum + 1)

  $('.calculator-item--minus').on 'click', () ->
    $result = $('.calculator-item--result')
    $minus = $('.calculator-item--minus')
    $minusShadow = $('.calculator-item--minusShadow')

    amountNum = +$result.text()

    if amountNum is 2
      $minus.hide()
      $minusShadow.show()

    $result.text(amountNum - 1)
