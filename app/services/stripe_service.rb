class StripeService
  def initialize(order, token)
    @order = order
    @token = token
  end

  protected

  def calculate_price_with_currency(amount = nil, currency = nil)
    amount = amount.present? ? amount : @order.price
    currency = currency.present? ? currency : @order.currency
    # 陣列裡是目前Stripe支援的不含小數單位的貨幣  https://support.stripe.com/questions/which-zero-decimal-currencies-does-stripe-support
    if %(BIF DJF JPY KRW PYG VND XAF XPF CLP GNF KMF MGA RWF VUV XOF).include? currency
      amount.to_i
    else
      # 單位是分，而且必須是正整數
      (BigDecimal(amount.to_s) * 100).to_i
    end
  end

  def charged?
    @order.payment_id.present?
  end

  def retrieve
    Stripe::Charge.retrieve(@order.payment_id) if charged?
  end
end
