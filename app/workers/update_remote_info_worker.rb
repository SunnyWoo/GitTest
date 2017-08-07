class UpdateRemoteInfoWorker
  include Sidekiq::Worker
  sidekiq_options queue: :deliver_order, retry: 3

  sidekiq_retry_in do |_count|
    1.hour
  end

  def perform(order_id)
    order = Order.find(order_id)
    remote_info_service = DeliverOrder::RemoteInfoService.new(order)
    unless remote_info_service.update
      SlackNotifier.send_msg("抛单失败 order_id: #{order_id}}")
      fail
    end
  end
end
