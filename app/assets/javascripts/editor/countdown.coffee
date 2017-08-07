@Countdown = (options) ->
  decrementCounter = ->
    updateStatus seconds
    if seconds is 0
      counterEnd()
      instance.stop()
    seconds--
    return
  timer = undefined
  instance = this
  seconds = options.seconds or 10
  updateStatus = options.onUpdateStatus or ->

  counterEnd = options.onCounterEnd or ->

  @start = ->
    clearInterval timer
    timer = 0
    seconds = options.seconds
    timer = setInterval(decrementCounter, 1000)
    return

  @stop = ->
    clearInterval timer
    return

  return