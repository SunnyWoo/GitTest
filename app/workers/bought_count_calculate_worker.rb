class BoughtCountCalculateWorker
  include Sidekiq::Worker

  def perform(order_id)
    Order.find(order_id).calculate_bought_count_for_product_template
  end
end
