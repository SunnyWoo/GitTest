$(document).on 'ready page:load', ->
  getShopUrl = window.location.pathname + window.location.search
  $('#sort_products a').each ->
    if $(this).attr('href') is getShopUrl
      $('#sort_products .val').text($(this).text())

  return