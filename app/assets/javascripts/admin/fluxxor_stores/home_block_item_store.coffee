HomeBlockItemStore = Fluxxor.createStore(
  initialize: ->
    @blockItems = []

    @bindActions(
      SET_HOME_BLOCK_ITEMS:   @onSetHomeBlockItems
      ADD_HOME_BLOCK_ITEM:    @onAddHomeBlockItem
      UPDATE_HOME_BLOCK_ITEM: @onUpdateHomeBlockItem
      REMOVE_HOME_BLOCK_ITEM: @onRemoveHomeBlockItem
    )

  getAll: (conditions) ->
    _.where(@blockItems, conditions)

  get: (id) ->
    _.find(@blockItems, id: id)

  onSetHomeBlockItems: (payload) ->
    @blockItems = payload.blockItems
    @emitChange()

  onAddHomeBlockItem: (payload) ->
    @blockItems.push(payload.blockItem)
    @emitChange()

  onUpdateHomeBlockItem: (payload) ->
    _.remove(@blockItems, id: payload.blockItem.id)
    @blockItems.push(payload.blockItem)
    @emitChange()

  onRemoveHomeBlockItem: (payload) ->
    _.remove(@blockItems, id: payload.blockItem.id)
    blockItem.position -= 1 for blockItem in @blockItems when blockItem.position > payload.blockItem.position
    @emitChange()

  emitChange: ->
    @blockItems = _.sortBy(@blockItems, 'position')
    @emit('change')
)

CPA.fluxxorStores.HomeBlockItemStore = new HomeBlockItemStore()
CPA.fluxxorStoreClasses.HomeBlockItemStore = HomeBlockItemStore
