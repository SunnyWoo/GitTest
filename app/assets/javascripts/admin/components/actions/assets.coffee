@CPA.Actions.Assets =
  disableColorize: (asset) ->
    @update(_.merge({}, asset, colorizable: false))

  enableColorize: (asset) ->
    @update(_.merge({}, asset, colorizable: true))

  update: (asset) ->
    data = humps.decamelizeKeys(asset: _.omit(asset, _.isNull))
    $.ajax(
      type: 'PATCH'
      url: CPA.path("/assets/#{asset.id}")
      data: data
    ).success (data) ->
      attributes = humps.camelizeKeys(data).asset
      CPA.dispatcher.dispatch(action: 'patchAsset', asset: asset, attributes: attributes)

  loadAll: (packageId) ->
    $.getJSON("/admin/asset_packages/#{packageId}/assets").success (data) ->
      assets = humps.camelizeKeys(data).assets
      CPA.dispatcher.dispatch(action: 'loadAssets', assets: assets)
