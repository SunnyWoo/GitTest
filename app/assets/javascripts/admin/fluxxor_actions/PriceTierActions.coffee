PriceTierActions =
  setPriceTiers: (PriceTiers) ->
    @dispatch('SET_PRICE_TIERS', priceTiers: priceTiers)

  loadPriceTiersFromServer: ->
    $.getJSON(CPA.path('/price_tiers')).success (data) =>
      priceTiers = data.price_tiers
      @dispatch('SET_PRICE_TIERS', priceTiers: priceTiers)

_.assign(CPA.fluxxorActions, PriceTierActions)
