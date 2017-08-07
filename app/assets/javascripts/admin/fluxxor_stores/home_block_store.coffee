HomeBlockStore = Fluxxor.createStore(
  initialize: ->
    @blocks = []

    @bindActions(
      SET_HOME_BLOCKS:   @onSetHomeBlocks
      ADD_HOME_BLOCK:    @onAddHomeBlock
      UPDATE_HOME_BLOCK: @onUpdateHomeBlock
      REMOVE_HOME_BLOCK: @onRemoveHomeBlock
    )

  getAll: -> @blocks

  get: (id) -> _.find(@blocks, id: id)

  onSetHomeBlocks: (payload) ->
    @blocks = payload.blocks
    @emitChange()

  onAddHomeBlock: (payload) ->
    @blocks.push(payload.block)
    @emitChange()

  onUpdateHomeBlock: (payload) ->
    _.remove(@blocks, id: payload.block.id)
    @blocks.push(payload.block)
    @emitChange()

  onRemoveHomeBlock: (payload) ->
    _.remove(@blocks, id: payload.block.id)
    block.position -= 1 for block in @blocks when block.position > payload.block.position
    @emitChange()

  emitChange: ->
    @blocks = _.sortBy(@blocks, 'position')
    @emit('change')
)

CPA.fluxxorStores.HomeBlockStore = new HomeBlockStore()
CPA.fluxxorStoreClasses.HomeBlockStore = HomeBlockStore
