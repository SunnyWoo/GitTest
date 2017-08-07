class Payment::NuandaoB2b < Payment
  def pay
    @order.logcraft_extra_info = to_hash
    @order.save
    if paid?
      @order.pay!
      @order.create_activity(:paid)
    else
      @order.create_activity(:pay_fail)
    end
  end

  def paid?
    NuandaoWebhookService::OrderConfirm.new(@order.id).execute
  end

  def to_hash
    super.merge(payment_id: @order.payment_id)
  end
end
