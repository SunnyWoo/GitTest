HomeBlockItemActions =
  getAllHomeBlockItems: ->
    CPA.Clients.HomeBlockItem.getAll()
       .done (blockItems) => @dispatch('SET_HOME_BLOCK_ITEMS', blockItems: blockItems)

  createHomeBlockItem: (attributes) ->
    CPA.Clients.HomeBlockItem.create(attributes)
       .done (blockItem) => @dispatch('ADD_HOME_BLOCK_ITEM', blockItem: blockItem)

  updateHomeBlockItem: (blockItem, attributes) ->
    CPA.Clients.HomeBlockItem.update(blockItem, attributes)
       .done (blockItem) => @dispatch('UPDATE_HOME_BLOCK_ITEM', blockItem: blockItem)

  destroyHomeBlockItem: (blockItem) ->
    CPA.Clients.HomeBlockItem.destroy(blockItem)
       .done (blockItem) => @dispatch('REMOVE_HOME_BLOCK_ITEM', blockItem: blockItem)

_.assign(CPA.fluxxorActions, HomeBlockItemActions)
