class Stripe::ChargeService < StripeService
  # NOT_PAID_ERROR = StandardError.new()
  attr_reader :error

  # Stripe::Charge.create的amount, currency, card為必要的，其他的是選填，方便在stripe那邊也記錄些該訂單的基本訊息，以利日後核對
  # card為stripe api端得到的以消費者信用卡訊息所產生的token，該token僅能使用一次
  # 付款成功時回傳true，其他異常狀況都會引發例外並儲存例外訊息並回傳false
  def execute
    @charge = Stripe::Charge.create(amount: calculate_price_with_currency,
                                    currency: @order.currency,
                                    description: @order.order_no,
                                    card: @token,
                                    receipt_email: @order.billing_info.email)
    @order.logcraft_extra_info = @order.payment_object.to_hash
    fail PaymentPriceConflictError unless @charge.amount == calculate_price_with_currency
    create_pay(@charge.id)
  rescue Stripe::CardError => e
    create_pay_fail "We are sorry! #{e.message}"
  rescue Stripe::InvalidRequestError
    create_pay_fail 'You must supply either a card or a customer id'
  rescue PaymentPriceConflictError => e
    WarningSender.perform_in(30.seconds, @order.id)
    create_pay_conflict e.message
  rescue => e
    create_pay_fail e.message
  end

  protected

  def create_pay_conflict(error_message)
    @order.create_activity(:pay_conflict, { message: error_message }.merge(payment_detail))
    @error = error_message
    false
  end

  def create_pay_fail(error_message)
    @order.errors.add(:base, error_message)
    @order.create_activity(:pay_fail, message: error_message)
    @error = error_message
    false
  end

  def create_pay(charge_id)
    @order.payment_id = charge_id
    @order.pay!
    @order.create_activity(:paid, payment_detail)
    true
  end

  def payment_detail
    {
      payment_method: @order.payment,
      payment_id:     @charge.id,
      payment_price:  @charge.amount,
      order_price:    calculate_price_with_currency
    }
  end
end
