jQuery ($) ->
  $(document).on 'ajax:success', '.del-work', ->
    product = $(this).parents('.product')
    product.animate(
      opacity: 0
      -> product.remove()
    )