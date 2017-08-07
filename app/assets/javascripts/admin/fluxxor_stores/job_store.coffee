JobStore = Fluxxor.createStore(
  initialize: ->
    @jobs = {}

    @bindActions(
      SET_JOB_STATUS: @onSetJobStatus
    )

  get: (id) ->
    @jobs[id] or= status: 'queued'

  onSetJobStatus: (payload) ->
    @jobs[payload.id] = payload.status
    @emitChange()

  emitChange: ->
    @emit('change')
)

CPA.fluxxorStores.JobStore = new JobStore()
CPA.fluxxorStoreClasses.JobStore = JobStore
