ProductCategoryStore = Fluxxor.createStore(
  initialize: ->
    @bindActions(
      SET_PRODUCT_CATEGORIES: @onSetProductCategories
    )

  getAll: -> @productCategories

  onSetProductCategories: ({ @productCategories }) ->
    @emitChange()

  emitChange: ->
    @emit('change')
)

CPA.fluxxorStores.ProductCategoryStore = new ProductCategoryStore()
CPA.fluxxorStoreClasses.ProductCategoryStore = ProductCategoryStore
