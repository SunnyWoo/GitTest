class Payment::CashOnDelivery < Payment
  def pay
    free_checking or begin
      @order.logcraft_extra_info = to_hash
      @order.pay!
      @order.create_activity(:paid)
    end
  end

  def paid?
    return true
  end
end
