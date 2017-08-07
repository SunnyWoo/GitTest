ProductModelActions =
  setProductModels: (productModels) ->
    @dispatch('SET_PRODUCT_MODELS', ProductModels: productModels)

  loadProductModelsFromServer: ->
    $.getJSON(CPA.path('/product_models?page=all')).success (data) =>
      productModels = humps.camelizeKeys(data.product_models)
      @dispatch('SET_PRODUCT_MODELS', productModels: productModels)

_.assign(CPA.fluxxorActions, ProductModelActions)
