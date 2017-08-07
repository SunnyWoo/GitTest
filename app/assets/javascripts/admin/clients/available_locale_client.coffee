AvailableLocaleClient =
  getAll: ->
    deferred = $.Deferred()
    $.jsonGET(
      CPA.path('/available_locales')
    ).success (data) -> deferred.resolve(humps.camelizeKeys(data).availableLocales)
    deferred.promise()

CPA.Clients.AvailableLocale = AvailableLocaleClient
