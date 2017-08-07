AvailableLocaleStore = Fluxxor.createStore(
  initialize: ->
    @availableLocales = []

    @bindActions(
      SET_AVAILABLE_LOCALES: @onSetAvailableLocales
    )

  getAll: ->
    @availableLocales

  isEmpty: ->
    @availableLocales.length is 0

  onSetAvailableLocales: (payload) ->
    @availableLocales = payload.availableLocales
    @emitChange()

  emitChange: ->
    @emit('change')
)

CPA.fluxxorStores.AvailableLocaleStore = new AvailableLocaleStore()
CPA.fluxxorStoreClasses.AvailableLocaleStore = AvailableLocaleStore
