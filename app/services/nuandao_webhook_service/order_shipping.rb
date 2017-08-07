class NuandaoWebhookService::OrderShipping < NuandaoWebhookService
  def initialize(order_id)
    super
  end

  def execute
    url = Settings.nuandao_b2b.order_shipping_url
    res = execute_post(url, order_shipping_params)
    order.create_activity(:nuandao_webhook_order_shipping,
                          message: '執行暖島物流狀態通知',
                          result: res,
                          url: url,
                          body: order_shipping_params)
    res
  end

  private

  def order_shipping_params
    {
      payment_id: order.payment_id,
      order_items: order.order_items.map do |order_item|
                     {
                       work_uuid: get_work_uuid(order_item.itemable),
                       status: order.aasm_state,
                       info: ''
                     }
                   end
    }
  end
end
