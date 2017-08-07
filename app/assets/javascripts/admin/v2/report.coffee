$(document).on 'page:change',  ->
  $('select#report_type').on 'change', (e) =>
    if e.target.value isnt 'product_model_sell_list'
      $('.for_starts_at_and_ends_at').removeClass('hide')
      # if $('.for_product_model_sell_list').hasClass('hide')
      #   return
      # else
      $('.for_year_and_month').addClass('hide')
    else
      $('.for_year_and_month').removeClass('hide')
      $('.for_starts_at_and_ends_at').addClass('hide')
