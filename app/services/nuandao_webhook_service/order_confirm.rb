class NuandaoWebhookService::OrderConfirm < NuandaoWebhookService
  def initialize(order_id)
    super
    fail ApplicationError, 'Payment id is null' unless @order.payment_id
    fail ApplicationError, "Order aasm_state must be pending, this state is #{@order.aasm_state}" unless @order.pending?
  end

  def execute
    url = Settings.nuandao_b2b.order_confirm_url
    res = execute_post(url, order_confirm_params)
    order.create_activity(:nuandao_webhook_order_confirm,
                          message: '執行暖島付款確認',
                          result: res,
                          url: url,
                          body: order_confirm_params)
    res
  end

  private

  def order_confirm_params
    {
      payment_id: order.payment_id,
      order_items: order.order_items.map do |order_item|
                     {
                       work_uuid: get_work_uuid(order_item.itemable),
                       quantity: order_item.quantity
                     }
                   end
    }
  end
end
