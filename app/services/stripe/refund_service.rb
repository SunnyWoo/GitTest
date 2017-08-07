class Stripe::RefundService < StripeService
  def initialize(order)
    @order = order
  end

  #執行退款動作，參數金額必填，填入的數字會自動幫你依據貨幣轉成stripe支援的格式
  #一次性的退款金額若等於訂單金額則直接完全退款，不然則是部分退款，部分退款可以反覆呼叫直到完全退款為止
  #退款成功時建立record並回傳true，發生例外時則記錄錯誤訊息並回傳false
  def execute(amount, note = nil)
    if @order.can_refund?
      refund_amount = calculate_price_with_currency(amount)
      charge = retrieve
      begin
        refund = charge.refunds.create(amount: refund_amount,
                                       metadata: { order_no: @order.order_no, note: note } )
        create_refund(amount, refund.id, note)
      rescue Stripe::InvalidRequestError => e
        @order.errors.add(:base, e.message)
        return false
      end
    end
  end

  protected

  def create_refund(amount, refund_id, note)
    @order.refunds.create( amount: amount, refund_no: refund_id, note: note)
    @order.part_refund! if @order.price_after_refund.round(2) > 0
    @order.refund! if @order.price_after_refund.round(2) == 0
    return true
  end
end
