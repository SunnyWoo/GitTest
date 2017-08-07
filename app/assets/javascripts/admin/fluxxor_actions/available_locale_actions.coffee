AvailableLocaleActions =
  getAllAvailableLocales: ->
    CPA.Clients.AvailableLocale.getAll()
       .done (availableLocales) => @dispatch('SET_AVAILABLE_LOCALES', availableLocales: availableLocales)

_.assign(CPA.fluxxorActions, AvailableLocaleActions)
