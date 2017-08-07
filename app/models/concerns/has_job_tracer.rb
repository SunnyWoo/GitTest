module HasJobTracer
  # To Refactor simalar process in OrderCancelWorker
  def kill_background_job(job_id)
    job = Sidekiq::ScheduledSet.new.find_job(job_id) ||
          Sidekiq::RetrySet.new.find_job(job_id) ||
          Sidekiq::DeadSet.new.find_job(job_id)
    job.try(:delete)
  end
end