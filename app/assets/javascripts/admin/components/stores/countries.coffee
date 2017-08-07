#= require eventEmitter

class Countries extends EventEmitter
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
      when 'setAllCountries' then @setAll(payload.countries)

@CPA.Stores.Countries = new Countries
