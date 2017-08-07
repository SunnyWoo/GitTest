#= require eventEmitter

class AssetPackages extends EventEmitter
  constructor: ->
    @models = []
    CPA.dispatcher.register(@dispatcher.bind(this))

  getAll: ->
    @models

  setAll: (models) ->
    @models = models
    @sort()

  add: (assetPackage) ->
    @models.push(assetPackage)
    @emit('add', assetPackage)
    @sort()

  get: (id) ->
    _.find(@models, (ap) -> ap.id is id)

  patch: (id, attributes) ->
    assetPackage = @get(id)
    _.extend(assetPackage, _.omit(attributes, 'position'))
    @sort()

  sort: ->
    @models = _.sortBy(@models, (ap) -> ap.position)
    @emit('change', @models)

  dispatcher: (payload) ->
    switch payload.action
      when 'addAssetPackage'      then @add(payload.assetPackage)
      when 'loadAllAssetPackages' then @setAll(payload.assetPackages)
      when 'loadSearchAssetPackages' then @setAll(payload.assetPackages)
      when 'patchAssetPackage'
        @patch(payload.assetPackage.id, payload.attributes)

@CPA.Stores.AssetPackages = new AssetPackages
