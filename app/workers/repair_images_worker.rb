class RepairImagesWorker
  include Sidekiq::Worker
  sidekiq_options queue: :deliver_order, retry: false

  def perform(id)
    DeliverErrorCollection.find(id).repair_images
  end
end
