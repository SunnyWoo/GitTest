TagClient =
  getAll: ->
    deferred = $.Deferred()
    $.jsonGET(
      CPA.path('/tags')
    ).success (data) -> deferred.resolve(humps.camelizeKeys(data).tags)
    deferred.promise()

  get: (id) ->
    deferred = $.Deferred()
    $.jsonGET(
      CPA.path("/tags/#{id}")
    ).success (data) -> deferred.resolve(humps.camelizeKeys(data).tag)
    deferred.promise()

  create: (attributes) ->
    deferred = $.Deferred()
    $.jsonPOST(
      CPA.path('/tags')
      humps.decamelizeKeys(tag: attributes)
    ).success (data) -> deferred.resolve(humps.camelizeKeys(data).tag)
     .error (xhr, status, error) -> deferred.reject(humps.camelizeKeys(JSON.parse(xhr.responseText)))
    deferred.promise()

  update: (tag, attributes) ->
    deferred = $.Deferred()
    $.jsonPATCH(
      CPA.path("/tags/#{tag.id}")
      humps.decamelizeKeys(tag: attributes)
    ).success (data) -> deferred.resolve(humps.camelizeKeys(data).tag)
     .error (xhr, status, error) -> deferred.reject(humps.camelizeKeys(JSON.parse(xhr.responseText)))
    deferred.promise()

  destroy: (tag) ->
    deferred = $.Deferred()
    $.jsonDELETE(
      CPA.path("/tags/#{tag.id}")
    ).success (data) -> deferred.resolve(humps.camelizeKeys(data).tag)
    deferred.promise()

CPA.Clients.Tag = TagClient
