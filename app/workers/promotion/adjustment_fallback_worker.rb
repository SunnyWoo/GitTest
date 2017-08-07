class Promotion::AdjustmentFallbackWorker
  include Sidekiq::Worker

  def perform(promotion_id)
    promotion = Promotion.find(promotion_id)
    promotion.fallback!
  end
end
