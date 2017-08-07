class Payment::Neweb::Alipay < Payment
  def pay
    free_checking or begin
      @order.logcraft_extra_info = to_hash
      @order.save.tap {
        @order.create_activity(:pay_ready)
      }
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
      paymenttype: 'Alipay',
      amount: @order.price.to_i,
      paytitle: 'commandp 我印商品',
      payterm: expired_at,
      paymemo: ''
    )
    response = HTTParty.post(neweb.query_url, body: payment_params)
    result = neweb.parse_query(response)

    return (result['rc'] == '-4' && result['rc2'] == '72')
  end

  def finish(params)
    neweb = NewebService.new
    @order.logcraft_extra_info = to_hash.merge(params)
    if neweb.valid_write_off_params?(params)
      @order.payment_info_will_change!
      @order.payment_info['webhook_params'] = params
      @order.pay!
      @order.create_activity(:paid)
    else
      @order.create_activity(:pay_fail, message: params.to_s, payment_method: 'neweb/alipay')
    end
  end

  def to_hash
    super.merge(writeoff_number: @order.payment_id)
  end

  def webpay_url(params = {})
    neweb = NewebService.new
    payment_params = neweb.payment_params(
      ordernumber: order_number,
      paymenttype: 'ALIPAY',
      amount: @order.price.to_i,
      paytitle: 'commandp 我印商品',
      paymemo: '',
      returnvalue: '0',
      nexturl: params[:next_url]
    )
    "#{neweb.payment_url}?#{payment_params.to_query}"
  end
end
