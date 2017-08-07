ProductCategoryActions =
  setProductCategories: (productCategories) ->
    @dispatch('SET_PRODUCT_CATEGORIES', ProductCategories: productCategories)

  loadProductCategoriesFromServer: ->
    $.getJSON(CPA.path('/product_categories')).success (data) =>
      productCategories = humps.camelizeKeys(data).productCategories
      @dispatch('SET_PRODUCT_CATEGORIES', productCategories: productCategories)

_.assign(CPA.fluxxorActions, ProductCategoryActions)
