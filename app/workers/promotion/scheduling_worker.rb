class Promotion::SchedulingWorker
  include Sidekiq::Worker

  def perform(promotion_id, event)
    promotion = Promotion.find(promotion_id)
    promotion.send("#{event}!") if promotion.send("may_#{event}?")
  end
end
