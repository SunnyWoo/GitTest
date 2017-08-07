class DefaultProduct
  constructor: ->
    @slideTimes = 0
    @random = 0
  
  stop: ->
    @stopped = true

  start: (oldRandom) ->
    return if @stopped

    elm = $('.img-slide-list')
    count = elm.length

    @random = oldRandom
    while @random is oldRandom or @random is 0
      @random = Math.floor(Math.random() * count)

    elm.attr('style', '')
    
    if @slideTimes % 4 is 0
      elm.eq(0).css(opacity: 1)
    else
      elm.eq(@random).css(opacity: 1)
    delayTime = 3000

    @slideTimes++

    setTimeout =>
      @start(@random)
    , delayTime

$(document).on 'page:change', ->
  DefaultProduct.lastDP?.stop()

  if $('.img-slide-list').length > 0
    DefaultProduct.lastDP = new DefaultProduct()
    DefaultProduct.lastDP.start()
