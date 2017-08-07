JobClient =
  startPolling: (jobId) ->
    deferred = $.Deferred()
    poll = ->
      $.getJSON(CPA.path("/jobs/#{jobId}"))
       .success (job) ->
         switch job.status
           when 'queued', 'working'
             deferred.notify(job)
             setTimeout(poll, 1000)
           when 'complete' then deferred.resolve(job)
           when 'failed'   then deferred.reject(job)
    poll()
    deferred.promise()

CPA.Clients.Job = JobClient
