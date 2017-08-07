class CreateWaterpackageWorker
  include Sidekiq::Worker

  def perform(work_id, payload)
    service = Campaign::WaterpackageWorkService.new(work_id, payload)
    service.perform
  end
end
