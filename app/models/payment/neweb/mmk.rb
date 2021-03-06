class Payment::Neweb::MMK < Payment
  attr_reader :error

  def pay
    free_checking or begin
      @order.logcraft_extra_info = to_hash
      @order.create_activity(:pay)
      neweb = NewebService.new
      expired_at = 5.days.from_now
      payment_params = neweb.payment_params(
        ordernumber: order_number,
        paymenttype: 'MMK',
        amount: @order.price.to_i,
        paytitle: 'commandp 我印商品',
        paymemo: '',
        duedate: expired_at
      )
      response = HTTParty.post(neweb.payment_url, body: payment_params)
      result = neweb.parse_query(response)
      if result['rc'] == '0'
        @order.payment_info_will_change!
        @order.payment_info['expired_at'] = expired_at
        @order.update(payment_id: result['paycode'])
        @order.logcraft_extra_info = to_hash.merge(result)
        @order.prepare_payment!.tap { @order.create_activity(:pay_ready) }
      else
        @order.errors.add(:base, result['message'])
        @order.logcraft_extra_info = to_hash.merge(result)
        @order.create_activity(:pay_fail, message: result['message'], payment_method: 'neweb/mmk')
        @error = result['message']
        false
      end
    end
  end

  #
  # 檢查金流端是否已收款
  #
  # @return boolean
  def paid?
    neweb = NewebService.new
    expired_at = 1.day.from_now
    payment_params = neweb.regetorder_params(
      ordernumber: order_number,
      paymenttype: 'MMK',
      amount: @order.price.to_i,
      paytitle: 'commandp 我印商品',
      paymemo: '',
      duedate: expired_at
    )
    response = HTTParty.post(neweb.query_url, body: payment_params)
    result = neweb.parse_query(response)
    (result['rc'] == '-4' && result['rc2'] == '72')
  end

  def finish(params)
    raise PaymentPriceConflictError.new(caused_by: params) if params['amount'].to_i != @order.price
    neweb = NewebService.new
    @order.logcraft_extra_info = to_hash.merge(params)
    if neweb.valid_write_off_params?(params)
      @order.payment_info_will_change!
      @order.payment_info['webhook_params'] = params
      @order.pay!
      @order.create_activity(:paid)
    else
      @order.create_activity(:pay_fail, message: params.to_s, payment_method: 'neweb/mmk')
    end
  end

  def to_hash
    super.merge(pay_code: pay_code)
  end

  def pay_code
    @order.payment_id
  end
end
