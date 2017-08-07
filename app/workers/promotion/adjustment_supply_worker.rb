class Promotion::AdjustmentSupplyWorker
  include Sidekiq::Worker

  def perform(promotion_id)
    promotion = Promotion.find(promotion_id)
    promotion.supply!
  end
end
