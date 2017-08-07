class Payment::Paypal < Payment
  def pay
    free_checking or begin
      @order.logcraft_extra_info = to_hash
      @order.create_activity(:pay)
      @payment = PaypalService.new(@order, payment_id: @order.payment_id)
      @payment.verify_with_paypal.tap { |result|
        @order.create_activity(result ? 'paid' : 'pay_fail')
      }
    end
  end

  def paid?
    payment = PaypalService.new(@order, payment_id: @order.payment_id)
    payment.approved?
  end

  def to_hash
    super.merge(payment_id: @order.payment_id)
  end

  def webpay_url(params = {})
    paypal_payment = PayPal::SDK::REST::Payment.new(
      intent: 'sale',
      redirect_urls: {
        return_url: params[:return_url],
        cancel_url: params[:cancel_url]
      },
      payer: {
        payment_method: 'paypal'
      },
      transactions: [
        {amount: {total: order_price, currency: @order.currency}}
      ]
    )
    if paypal_payment.create
      unless (payment_price = paypal_payment.transactions.first.amount.total.to_f) == @order.price
        raise PaymentPriceConflictError.new(
                caused_by: {
                  payment_method: @order.payment,
                  payment_id:     paypal_payment.id,
                  payment_price:  payment_price,
                  order_price:    @order.price
                })
      end
      @order.update(payment_id: paypal_payment.id)
      paypal_payment.links.find { |link| link.rel == 'approval_url' }.href
    else
      message = paypal_payment.error.details.map(&:issue).join("\n")
      raise Payment::Error.new(message)
    end
  end

  def order_price
    case @order.currency
    when 'TWD', 'JPY' then '%d'   % @order.price.to_i
    else                   '%.2f' % @order.price
    end
  end
end
