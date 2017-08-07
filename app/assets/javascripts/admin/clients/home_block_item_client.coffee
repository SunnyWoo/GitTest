HomeBlockItemClient =
  getAll: ->
    deferred = $.Deferred()

    $.jsonGET(CPA.path('/home_block_items'))
     .success (data) -> deferred.resolve(humps.camelizeKeys(data).blockItems)

    deferred.promise()

  create: (attributes) ->
    deferred = $.Deferred()

    $.jsonPOST(
      CPA.path('/home_block_items')
      humps.decamelizeKeys(blockItem: attributes)
    ).success (data) -> deferred.resolve(humps.camelizeKeys(data).blockItem)

    deferred.promise()

  update: (blockItem, attributes) ->
    deferred = $.Deferred()

    $.jsonPATCH(
      CPA.path("/home_block_items/#{blockItem.id}")
      humps.decamelizeKeys(blockItem: attributes)
    ).success (data) -> deferred.resolve(humps.camelizeKeys(data).blockItem)

    deferred.promise()

  destroy: (blockItem) ->
    deferred = $.Deferred()

    $.jsonDELETE(
      CPA.path("/home_block_items/#{blockItem.id}")
    ).success (data) -> deferred.resolve(humps.camelizeKeys(data).blockItem)

    deferred.promise()

CPA.Clients.HomeBlockItem = HomeBlockItemClient
