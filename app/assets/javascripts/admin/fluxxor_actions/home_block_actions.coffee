HomeBlockActions =
  getAllHomeBlocks: ->
    CPA.Clients.HomeBlock.getAll()
       .done (blocks) => @dispatch('SET_HOME_BLOCKS', blocks: blocks)

  createHomeBlock: ->
    CPA.Clients.HomeBlock.create()
       .done (block) => @dispatch('ADD_HOME_BLOCK', block: block)

  updateHomeBlock: (block, attributes) ->
    CPA.Clients.HomeBlock.update(block, attributes)
       .done (block) => @dispatch('UPDATE_HOME_BLOCK', block: block)

  destroyHomeBlock: (block) ->
    CPA.Clients.HomeBlock.destroy(block)
       .done (block) => @dispatch('REMOVE_HOME_BLOCK', block: block)

_.assign(CPA.fluxxorActions, HomeBlockActions)
