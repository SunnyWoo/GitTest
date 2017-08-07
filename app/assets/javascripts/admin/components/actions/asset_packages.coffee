@CPA.Actions.AssetPackages =
  create: (assetPackage) ->
    CPA.dispatcher.dispatch(action: 'addAssetPackage', assetPackage: assetPackage)

  patch: (assetPackage, attributes) ->
    CPA.dispatcher.dispatch(action: 'patchAssetPackage', assetPackage: assetPackage, attributes: attributes)

  update: (assetPackage) ->
    data = humps.decamelizeKeys(assetPackage: _.omit(assetPackage, _.isNull))
    $.ajax(
      type: 'PATCH'
      url: CPA.path("/asset_packages/#{assetPackage.id}")
      data: data
      success: (data) ->
        attributes = humps.camelizeKeys(data).assetPackage
        CPA.dispatcher.dispatch(action: 'patchAssetPackage', assetPackage: assetPackage, attributes: attributes)
        ReactMiniRouter.navigate('/')
      error: (e) ->
        errors = JSON.parse(e.responseText)
        CPA.dispatcher.dispatch(action: 'invalidAssetPackage', errors: errors)
    )

  enable: (assetPackage) ->
    @update(_.merge({}, assetPackage, available: true)).error (e) ->
      data = JSON.parse(e.responseText)
      errorMessages = for field, errors of data
        "#{field}: #{errors.join(', ')}"
      CPA.Actions.Flash.error(errorMessages.join('<br />'))

  disable: (assetPackage) ->
    @update(_.merge({}, assetPackage, available: false)).error (e) ->

  insertTo: (assetPackage, insertPosition) ->
    data = humps.decamelizeKeys(assetPackage: { insertPosition: insertPosition })
    $.ajax(
      type: 'PATCH'
      url: CPA.path("/asset_packages/#{assetPackage.id}")
      data: data
      success: (data) ->
        CPA.Actions.AssetPackages.loadAll()
      error: (e) ->
        errors = JSON.parse(e.responseText)
        CPA.dispatcher.dispatch(action: 'invalidAssetPackage', errors: errors)
    )

  load: (id) ->
    unless CPA.Stores.AssetPackages.get(id)
      $.getJSON(CPA.path("/asset_packages/#{id}")).success (data) ->
        assetPackage = humps.camelizeKeys(data).assetPackage
        CPA.dispatcher.dispatch(action: 'addAssetPackage', assetPackage: assetPackage)

  show: (id) ->
    assetPackage = CPA.Stores.AssetPackages.get(id)
    if assetPackage
      CPA.dispatcher.dispatch(action: 'showAssetPackage', assetPackage: assetPackage)
    else
      $.getJSON(CPA.path("/asset_packages/#{id}")).success (data) ->
        assetPackage = humps.camelizeKeys(data).assetPackage
        CPA.dispatcher.dispatch(action: 'addAssetPackage', assetPackage: assetPackage)

  edit: (id) ->
    assetPackage = CPA.Stores.AssetPackages.get(id)
    if assetPackage
      CPA.dispatcher.dispatch(action: 'editAssetPackage', assetPackage: assetPackage)
    else
      $.getJSON(CPA.path("/asset_packages/#{id}")).success (data) ->
        assetPackage = humps.camelizeKeys(data).assetPackage
        CPA.dispatcher.dispatch(action: 'addAssetPackage', assetPackage: assetPackage)

  loadAll: ->
    $.getJSON(CPA.path("/asset_packages")).success (data) ->
      assetPackages = humps.camelizeKeys(data).assetPackages
      CPA.dispatcher.dispatch(action: 'loadAllAssetPackages', assetPackages: assetPackages)

  search: (filters) ->
    filtersData = {}
    for filter in filters
      filtersData[filter.type] = filter.value
    queryData =
      translationsNameCont: filtersData.search
      beginAtGteq: filtersData.begins
      endAtGteq: filtersData.ends
    queryData = humps.decamelizeKeys(_.omit(queryData, _.isEmpty))
    scopeData = if filtersData.status then humps.decamelize(filtersData.status) else ''
    $.getJSON(CPA.path("/asset_packages"), { q: queryData, scope: scopeData }).success (data) ->
      assetPackages = humps.camelizeKeys(data).assetPackages
      CPA.dispatcher.dispatch(action: 'loadSearchAssetPackages', assetPackages: assetPackages)

  loadCategory: () ->
    $.getJSON(CPA.path('/asset_package_categories')).success (data) ->
      assetPackageCategories = humps.camelizeKeys(data).assetPackageCategories
      CPA.dispatcher.dispatch(action: 'loadAssetPackageCategories', assetPackageCategories: assetPackageCategories)
