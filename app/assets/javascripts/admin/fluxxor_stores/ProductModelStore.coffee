ProductModelStore = Fluxxor.createStore(
  initialize: ->
    @bindActions(
      SET_PRODUCT_MODELS: @onSetProductModels
    )

  getAll: -> @productModels

  onSetProductModels: ({ @productModels }) ->
    @emitChange()

  emitChange: ->
    @emit('change')
)

CPA.fluxxorStores.ProductModelStore = new ProductModelStore()
CPA.fluxxorStoreClasses.ProductModelStore = ProductModelStore
