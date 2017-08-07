#= require eventEmitter

class Designers extends EventEmitter
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
      when 'setAllDesigners' then @setAll(payload.designers)

@CPA.Stores.Designers = new Designers
