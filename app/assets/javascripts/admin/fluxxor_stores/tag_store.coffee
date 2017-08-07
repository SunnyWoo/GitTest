TagStore = Fluxxor.createStore(
  initialize: ->
    @tags = []

    @bindActions(
      SET_TAGS: @onSetTags
      ADD_TAG: @onAddTag
      UPDATE_TAG: @onUpdateTag
      REMOVE_TAG: @onRemoveTag
    )

  getAll: ->
    @tags

  get: (id) ->
    _.find(@tags, id: id)

  onSetTags: (payload) ->
    @tags = payload.tags
    @emitChange()

  onAddTag: (payload) ->
    @tags.push(payload.tag)
    @emitChange()

  onUpdateTag: (payload) ->
    _.remove(@tags, id: payload.id)
    @tags.push(payload.tag)
    @emitChange()

  onRemoveTag: (payload) ->
    _.remove(@tags, id: payload.id)
    @emitChange()

  emitChange: ->
    @emit('change')
)

CPA.fluxxorStores.TagStore = new TagStore()
CPA.fluxxorStoreClasses.TagStore = TagStore
