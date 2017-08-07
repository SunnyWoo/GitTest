class PushRemoteInfoWorker
  include Sidekiq::Worker
  sidekiq_options queue: :deliver_order, retry: 5

  sidekiq_retry_in do |_count|
    1.hour
  end

  sidekiq_retries_exhausted do |msg|
    SlackNotifier.send_msg("抛单信息同步失败 order_id: #{msg['args']}")
  end

  def perform(order_id)
    order = Order.find(order_id)
    remote_info_service = DeliverOrder::RemoteInfoService.new(order)
    unless remote_info_service.push
      Rails.logger.info "push remote info error: #{remote_info_service.errors.full_messages.join(', ')}"
      fail
    end
  end
end
