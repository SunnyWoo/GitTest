#= require flux

class AppDispatcher extends Flux.Dispatcher
  constructor: ->
    super
    @register (payload) ->
      console.log 'Dispatch with payload:', payload

@CPA.dispatcher = new AppDispatcher
