@CPA.Actions.Designers =
  loadAll: ->
    $.getJSON(CPA.path('/designers')).success (data) ->
      designers = humps.camelizeKeys(data.designers)
      CPA.dispatcher.dispatch(action: 'setAllDesigners', designers: designers)
