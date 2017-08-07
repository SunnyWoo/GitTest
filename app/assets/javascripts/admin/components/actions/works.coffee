@CPA.Actions.Works =
  loadAll: ->
    $.getJSON(CPA.path('/works?q[work_type_eq]=3&page=all')).success (data) ->
      works = humps.camelizeKeys(data.works)
      CPA.dispatcher.dispatch(action: 'setAllWorks', works: works)
