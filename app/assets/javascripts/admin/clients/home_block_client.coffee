HomeBlockClient =
  getAll: ->
    deferred = $.Deferred()

    $.jsonGET(CPA.path('/home_blocks'))
     .success (data) -> deferred.resolve(humps.camelizeKeys(data).homeBlocks)

    deferred.promise()

  create: ->
    deferred = $.Deferred()

    $.jsonPOST(
      CPA.path('/home_blocks')
    ).success (data) -> deferred.resolve(humps.camelizeKeys(data).homeBlock)

    deferred.promise()

  update: (block, attributes) ->
    deferred = $.Deferred()

    $.jsonPATCH(
      CPA.path("/home_blocks/#{block.id}")
      humps.decamelizeKeys(block: attributes)
    ).success (data) -> deferred.resolve(humps.camelizeKeys(data).homeBlock)

    deferred.promise()

  destroy: (block) ->
    deferred = $.Deferred()

    $.jsonDELETE(
      CPA.path("/home_blocks/#{block.id}")
    ).success (data) -> deferred.resolve(humps.camelizeKeys(data).homeBlock)

    deferred.promise()

CPA.Clients.HomeBlock = HomeBlockClient
