$ ->

  send = (params)->
    window.APPIER_RETARGET.send(params)

  window.COMMAND_APPIER =

    followCategory: (category_id) ->
      send({
        't': 'product_list'
        'contenxt': category_id
      })

    addToCart: (product_id_array) ->
      send({
        't': 'cart'
        'content': product_id_array
      })

  $(document).on 'page:change', ->

    CA = window.COMMAND_APPIER

    Events =
      shopsIndex : (data) ->
        if data?
          CA.followCategory(data)

      cartIndex: (datas)->
        product_id_arr = _.map datas, (item) =>
          id = item.uuid
        if product_id_arr.length > 0
          CA.addToCart(product_id_arr)

    $bodyClass = $('body').attr('class')

    if _.indexOf($bodyClass.split(' '), 'campaign') isnt -1

      $('.product-mobile').on 'click', '.add_to_cart', ->
        Events.cartIndex(cart.order_items)

      Events.shopsIndex($('#campaing_inof').data('key'))



