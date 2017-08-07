class Payment::NewebMPP < Payment
  def pay
    free_checking or begin
      @order.logcraft_extra_info = to_hash
      @order.save.tap { @order.create_activity(:pay) }
    end
  end

  #
  # 檢查金流端是否已收款
  #
  # @return boolean
  def paid?
    return false
  end

  def finish(params)
    raise PaymentPriceConflictError.new(caused_by: params) if params['Amount'].to_i != @order.price
    neweb = NewebMPPService.new
    @order.logcraft_extra_info = to_hash.merge(params)
    @order.payment_info_will_change!
    @order.payment_info['webhook_params'] = params
    if neweb.valid_callback_params?(params)
      if params['PRC'] == '0' && params['SRC'] == '0'
        @order.pay!
        @order.create_activity(:paid)
      else
        @order.create_activity(:pay_fail,
                              { message: params.to_s,
                                payment_method: 'neweb_mpp'
                              }.merge(params))
      end
    else
      @order.payment_info['invalid'] = true
      @order.save
      @order.create_activity(:pay_fail)
    end
  end

  def to_hash
    super.merge(payment_id: @order.payment_id)
  end

  def webpay_url(params = {})
    neweb = NewebMPPService.new
    params = neweb.payment_params(ordernumber: order_number,
                                  amount:      @order.price.to_i,
                                  orderurl:    params[:order_url],
                                  returnurl:   params[:return_url])
    neweb.payment_url(params)
  end
end
