jQuery ($) ->
  $(document).on 'ajax:success', '.shopping-cart', ->
    originalProduct = $(this).parents('.product')
    product = originalProduct.clone()
    product.find('.product-name, .info').remove()
    originalProduct.after(product)
    product.css(position: 'absolute', zIndex: 10000).css(originalProduct.offset())

    cart = $('.icons-topbar_shoppingcart_normal')
    product.find('img').css(maxWidth: '100%', maxHeight: '100%')
    product.animate(
      left: cart.offset().left
      top: cart.offset().top
      opacity: 0
      width: 0
      height: 0
      -> product.remove()
    )

  $(document).on 'ajax:success', '.add_to_cart', ->
    originalProduct = $(this).parents('.details')
    product = originalProduct.find('.detail-imgs').clone().find('.thumb-list').remove().end()
    originalProduct.after(product)
    product.css(position: 'absolute', zIndex: 10000).css(originalProduct.offset())
    cart = $('.icons-topbar_shoppingcart_normal')
    product.find('img').css(maxWidth: '100%', maxHeight: '100%')
    product.animate(
      left: cart.offset().left
      top: cart.offset().top
      opacity: 0
      width: 0
      height: 0
      -> product.remove()
    )
