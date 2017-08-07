TagActions =
  getAllTags: ->
    CPA.Clients.Tag.getAll()
       .done (tags) => @dispatch('SET_TAGS', tags: tags)

  getTag: (id) ->
    CPA.Clients.Tag.get(id)
       .done (tag) => @dispatch('ADD_TAG', tag: tag)

  createTag: (attributes) ->
    CPA.Clients.Tag.create(attributes)
       .done (tag) => @dispatch('ADD_TAG', tag: tag)

  updateTag: (tag, attributes = tag) ->
    CPA.Clients.Tag.update(tag, attributes)
       .done (tag) => @dispatch('UPDATE_TAG', tag: tag)

  destroyTag: (tag) ->
    CPA.Clients.Tag.destroy(tag)
       .done (tag) => @dispatch('REMOVE_TAG', tag: tag)

_.assign(CPA.fluxxorActions, TagActions)
