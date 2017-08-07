window.Commandp.Ua ||= {}
window.Commandp.Ua.EC ||= {}

class Commandp.Ua.EC
  constructor: (@element) ->
    @id = @element.data('uuid')
    @name = @element.data('name')
    @category = @element.data('category')
    @brand = @element.data('brand')
    @list = @element.data('list')
    @price = @element.data('price') || 0
    @currency = @element.data('currency') || ''
    @quantity = @element.data('quantity') || 1
    @step = @element.data('step') || 0
    @option = @element.data('option') || ''

  addImpression: ->
    ga "ec:addImpression",
      id: @id
      name: @name
      category: @category
      brand: @brand
      list: @list
    return

  addProduct: (action, event)->
    ga "ec:addProduct",
      id: @id
      name: @name
      category: @category
      brand: @brand

    if action is 'detail'
      ga "ec:setAction", action,
        list: @list
    else
      ga "ec:setAction", action

    ga "send", "event", "UX", "click", event

  onCheckout: ->
    ga "ec:addProduct",
      id: @id
      name: @name
      category: @category
      brand: @brand
      price: @price
      quantity: @quantity

    ga "ec:setAction", "checkout",
      step: @step
      option: @option

    ga "send", "event", "Cart", "action", (@step + ', ' + @list)

  onPurchaseAddProduct: ->
    ga "ec:addProduct",
      id: @id
      name: @name
      category: @category
      brand: @brand
      price: @price
      quantity: @quantity

    return

$(document).on 'ready page:load', ->
  if ga?
    $('.ga_ec_data').each ->
      new Commandp.Ua.EC($(this)).addImpression()

    $('.ga_checkout_data').each ->
      new Commandp.Ua.EC($(this)).onCheckout()

    $('.ga_order_data').each ->
      new Commandp.Ua.EC($(this)).onPurchaseAddProduct()

    $('[data-behavior~=add_to_cart]').on 'click', ->
      ga = $(this).data('ga')
      thisEvent = $(this).data('behavior')
      new Commandp.Ua.EC($(ga.target)).addProduct(ga.name, thisEvent)

    $('[data-behavior~=detail_impression]').on 'click', ->
      ga = $(this).data('ga')
      thisEvent = $(this).data('behavior')
      new Commandp.Ua.EC($(ga.target)).addProduct(ga.name, thisEvent)

    $('.ga-event').on 'click touch', ->
      $t = $(this)
      eventCate = $t.data('gaEventCategory')
      eventAction = $t.data('gaEventAction')
      eventLabel = $t.data('gaEventLabel')
      ga "send", "event", eventCate, eventAction, eventLabel

    # log campaing GA event add to cart
    $('.campaign_works [data-behavior~=add_to_cart]').on 'click', ->
      dom = $(this)
      WorkName = dom.data('work')
      ModelName = dom.data('model')
      ga 'send', 'event', $('.campaign_works').data('gaCategory'), 'Add to Cart', "#{WorkName} - #{ModelName}"

  return
