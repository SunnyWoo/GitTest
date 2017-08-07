#= require eventEmitter

class AssetPackageForm extends EventEmitter
  constructor: ->
    CPA.dispatcher.register(@dispatcher.bind(this))

  get: ->
    @assetPackage or {}

  load: (assetPackage) ->
    @assetPackage = _.omit(assetPackage, 'position')
    @emit('load', assetPackage)

  update: (attributes) ->
    _.extend(@assetPackage, _.omit(attributes, 'position'))
    @emit('update', @assetPackage)

  dispatcher: (payload) ->
    switch payload.action
      when 'addAssetPackage', 'editAssetPackage'
        @load(payload.assetPackage)
      when 'patchAssetPackage'
        if payload.assetPackage.id is @assetPackage?.id
          @update(payload.attributes)
      when 'invalidAssetPackage'
        @emit('error', payload.errors)
      when 'loadAssetPackageCategories'
        @emit('loadCategories', payload.assetPackageCategories)

@CPA.Stores.AssetPackageForm = new AssetPackageForm
