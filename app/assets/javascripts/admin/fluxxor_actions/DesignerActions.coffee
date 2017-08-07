DesignerActions =
  setDesigners: (designers) ->
    @dispatch('SET_DESIGNERS', designers: designers)

  loadDesignersFromServer: ->
    $.getJSON(CPA.path('/designers?page=all')).success (data) =>
      designers = humps.camelizeKeys(data.designers)
      @dispatch('SET_DESIGNERS', designers: designers)

_.assign(CPA.fluxxorActions, DesignerActions)
