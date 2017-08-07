DesignerStore = Fluxxor.createStore(
  initialize: ->
    @bindActions(
      SET_DESIGNERS: @onSetDesigners
    )

  getAll: -> @designers

  onSetDesigners: ({ @designers }) ->
    @emitChange()

  emitChange: ->
    @emit('change')
)

CPA.fluxxorStores.DesignerStore = new DesignerStore()
CPA.fluxxorStoreClasses.DesignerStore = DesignerStore
