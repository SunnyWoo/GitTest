class DeliverOrder::CheckFailedService
  attr_reader :time_start, :time_end, :website, :headers

  def initialize(time_start = nil)
    @time_start = time_start || Time.zone.now.prev_month
    @time_end = Time.zone.now.end_of_day
    @website = Settings.deliver_order.website
    @headers = { 'Accept' => 'application/vnd.commandp.v3+json' }
  end

  def self.deliver_failed_info
    # 抛单开始日期： 2015/12/25,
    current_time = Time.zone.now
    failed_order_info = []
    approved_at_between = current_time.prev_month..current_time
    orders = Order.includes(order_items: [itemable: :product])
                  .where(delivered_at: nil, approved_at: approved_at_between)
    orders.find_each do |order|
      if order.have_deliver_order_items?
        failed_order_info << { order_id: order.id, order_no: order.order_no }
      end
    end
    failed_order_info
  end

  def receive_failed_order_ids
    order_ids = local_order_ids - remote_order_ids
    { status: true, order_ids: order_ids }
  rescue => e
    { status: false, error: e.to_s }
  end

  private

  def local_order_ids
    @local_order_ids ||= Order.where(delivered_at: time_start..time_end, deliver_complete: false).pluck(:id)
  end

  def remote_order_ids
    DeliverOrder::AuthorizerRedis.new.redis_del if call_remote_order_ids.code.to_i == 401
    @remote_order_ids ||= call_remote_order_ids['remote_ids']
  end

  def call_remote_order_ids
    remote_url = "#{@website}/api/deliver_order/remote_infos/"
    @remote_response ||= HTTParty.get(remote_url,
                                      headers: headers,
                                      query: { 'access_token' => access_token, 'remote_ids' => @local_order_ids })
  end

  def access_token
    DeliverOrder::AuthorizerRedis.new.retrieve_access_token
  end
end
