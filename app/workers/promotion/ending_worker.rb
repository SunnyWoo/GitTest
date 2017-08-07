class Promotion::EndingWorker
  include Sidekiq::Worker

  def perform(promotion_id)
    Promotion.find(promotion_id).complete!
  end
end
