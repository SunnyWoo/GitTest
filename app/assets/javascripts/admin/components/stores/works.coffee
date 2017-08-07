#= require eventEmitter

class Works extends EventEmitter
  constructor: ->
    @models = []
    CPA.dispatcher.register(@dispatcher.bind(this))

  getAll: ->
    @models

  setAll: (models) ->
    @models = models
    @emit('change', @models)

  dispatcher: (payload) ->
    switch payload.action
      when 'setAllWorks' then @setAll(payload.works)

@CPA.Stores.Works = new Works
