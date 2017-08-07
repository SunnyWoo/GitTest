class StandardizedWorkBoughtCountCalculateWorker
  include Sidekiq::Worker

  def perform(order_id)
    Order.find(order_id).calculate_bought_count_for_standardized_work
  end
end
