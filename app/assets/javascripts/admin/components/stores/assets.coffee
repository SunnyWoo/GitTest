#= require eventEmitter

class Assets extends EventEmitter
  constructor: ->
    CPA.dispatcher.register(@dispatcher.bind(this))

  getPackage: ->
    @assetPackage or {}

  loadPackage: (assetPackage) ->
    @assetPackage = _.omit(assetPackage, 'position')
    @emit('load')

  updatePackage: (attributes) ->
    _.extend(@assetPackage, _.omit(attributes, 'position'))
    @emit('update')

  getAll: ->
    @assets or []

  loadAll: (assets) ->
    @assets = assets
    @emit('load')

  get: (id) ->
    _.find(@getAll(), (a) -> a.id is id)

  patch: (id, attributes) ->
    asset = @get(id)
    _.extend(asset, _.omit(attributes, 'position'))
    @emit('update')

  dispatcher: (payload) ->
    switch payload.action
      when 'addAssetPackage', 'showAssetPackage'
        @loadPackage(payload.assetPackage)
      when 'patchAssetPackage'
        if payload.assetPackage.id is @assetPackage?.id
          @updatePackage(payload.attributes)
      when 'loadAssets'
        @loadAll(payload.assets)
      when 'patchAsset'
        @patch(payload.asset.id, payload.attributes)

@CPA.Stores.Assets = new Assets
