class Payment::Striper < Payment
  def pay
    free_checking or begin
      @order.logcraft_extra_info = to_hash
      @token = @order.payment_id
      Stripe::ChargeService.new(@order, @token).execute
    end
  end

  def paid?
    return false if @order.payment_id.blank?
    stripe = StripeService.new(@order, stripe_token: @order.payment_id)
    stripe.retrieve
    return true
  rescue Stripe::InvalidRequestError
    return false
  end
end
