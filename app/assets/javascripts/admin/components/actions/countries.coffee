@CPA.Actions.Countries =
  loadAll: ->
    $.getJSON(CPA.path('/countries')).success (data) ->
      countries = humps.camelizeKeys(data.countries)
      CPA.dispatcher.dispatch(action: 'setAllCountries', countries: countries)
