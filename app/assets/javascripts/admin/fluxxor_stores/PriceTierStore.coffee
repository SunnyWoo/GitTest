PriceTierStore = Fluxxor.createStore(
  initialize: ->
    @bindActions(
      SET_PRICE_TIERS: @onSetPriceTiers
    )

  getAll: -> @priceTiers

  onSetPriceTiers: ({ @priceTiers }) ->
    @emitChange()

  emitChange: ->
    @emit('change')
)

CPA.fluxxorStores.PriceTierStore = new PriceTierStore()
CPA.fluxxorStoreClasses.PriceTierStore = PriceTierStore
