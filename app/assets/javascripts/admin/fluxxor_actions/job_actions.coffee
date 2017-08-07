JobActions =
  startPollingJob: (jobId) ->
    dispatcher = (job) => @dispatch('SET_JOB_STATUS', id: jobId, status: job)

    CPA.Clients.Job.startPolling(jobId)
       .done(dispatcher)
       .fail(dispatcher)
       .progress(dispatcher)

_.assign(CPA.fluxxorActions, JobActions)
