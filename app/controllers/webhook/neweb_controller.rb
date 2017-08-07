class Webhook::NewebController < ActionController::Base
  def writeoff
    # 訂單使用藍新付款 若重新請求付款方式 訂單編號會更改 會導致 callback 失敗
    # https://app.asana.com/0/14529796148307/28231481273943
    @order_no = params[:ordernumber]
    find_order_and_finish
  end

  private

  def find_order_and_finish
    @order_no = @order_no.present? ? @order_no.split('-').first : nil
    Order.find_by(order_no: @order_no).try do |order|
      order.logcraft_source = { channel: 'webhook' }
      order.payment_object.finish(params)
    end
    render nothing: true
  rescue PaymentPriceConflictError => e
    Order.find_by(order_no: @order_no).try do |order|
      payment_price = e.as_json[:detail]['amount'] || e.as_json[:detail]['Amount']
      order.create_activity(:pay_conflict, message:        e.message,
                                           payment_method: order.payment,
                                           payment_price:  payment_price,
                                           order_price:    order.price)
      WarningSender.perform_in(30.seconds, order.id)
    end
    render nothing: true
  end
end
