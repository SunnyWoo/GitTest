getECData = (elem) ->
  data = $(elem).data()

  {
    brand: data.ecBrand
    category: data.ecCategory
    id: data.ecId
    name: data.ecName
    price: data.ecPrice
  }

###
Here is example:
<div id="example-product"
  data-ec-brand="B2B2C商店: 歐提斯 Store" data-ec-category="easycard_smartcards" data-ec-id="8a5de1ea-5a4f-11e6-89bd-acbc32d3cfdf"
  data-ec-name="Italian Beauty"
  data-ec-price="349.0"
>.....</div>

// send data to ga
$("#example-product").ecProductImpressionByScroll()
###
$.fn.extend
  ecProductImpressionByScroll: () ->
    return this if this.length == 0
    this.each (index) ->
      data = $.extend(getECData(this), { position: index })
      ga('ec:addImpression', data)

    ga('send', 'event', 'Scroll Tracking', 'scroll', 'Product Impression')
    return this

  ecProductClick: (options = {}) ->
    return this if this.length == 0
    return this.each (index) ->
      data = getECData(this)
      ga('ec:addProduct', data)
      ga('ec:setAction', 'click')
      ga('send', 'event', 'UX', 'click', 'Click a Product', {
        hitCallback: options.hitCallback || ->
      })

  ecProductDetailView: () ->
    return this if this.length == 0
    return this.each (index) ->
      data = getECData(this)
      ga('ec:addProduct', data)
      ga('ec:setAction', 'detail')
      ga('send', 'event', 'UX', 'detail', 'Enter Detail View')

  ecProductAdd: (options) ->
    return this if this.length == 0
    return this.each (index) ->
      data = $.extend(getECData(this), quantity: options.quantity)
      ga('ec:addProduct', data)
      ga('ec:setAction', 'add')
      ga('send', 'event', 'UX', 'add', 'Add to Cart')
