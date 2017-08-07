class NuandaoWebhookService
  attr_reader :order

  def initialize(order_id)
    @order = Order.includes(order_items: :itemable).find(order_id)
  end

  private

  def execute_post(url, body)
    body = body.to_json if body.is_a?(Hash)
    res = HTTParty.post(url, body: body)
    res = JSON.parse(res) if res.is_a?(String)
    res['status'] == 'ok'
  rescue => e
    order.create_activity(:execute_post, message: 'Post to nuandao webhook error.', error: e)
    false
  end

  def get_work_uuid(itemable)
    itemable.try(:original_work_id).present? ? itemable.original_work.uuid : itemable.uuid
  end
end
