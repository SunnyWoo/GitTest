# Public: A temporary storage class for pending matters.

class @PendingJobs
  constructor: ->
    @jobs = []
  
  getObjs: ->
    @jobs

  add: (key) ->
    @jobs.push(key)

  remove: (key) ->
    _.pull(@jobs, key)