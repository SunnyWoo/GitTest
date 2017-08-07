class Payment
  PAYMENT_CLASS_MAPPING = {
    'paypal'                  => Payment::Paypal,
    'cash_on_delivery'        => Payment::CashOnDelivery,
    'neweb/atm'               => Payment::Neweb::ATM,
    'neweb/mmk'               => Payment::Neweb::MMK,
    'neweb/alipay'            => Payment::Neweb::Alipay,
    'neweb_mpp'               => Payment::NewebMPP,
    'stripe'                  => Payment::Striper,
    'pingpp_alipay'           => Payment::PingppAlipay,
    'pingpp_alipay_wap'       => Payment::PingppAlipayWap,
    'pingpp_wx'               => Payment::PingppWx,
    'pingpp_upacp'            => Payment::PingppUpacp,
    'pingpp_bfb'              => Payment::PingppBfb,
    'pingpp_upacp_wap'        => Payment::PingppUpacpWap,
    'pingpp_alipay_qr'        => Payment::PingppAlipayQr,
    'pingpp_alipay_pc_direct' => Payment::PingppAlipayPcDirect,
    'camera360'               => Payment::Camera360,
    'pingpp_upacp_pc'         => Payment::PingppUpacpPc,
    'pingpp_wx_pub_qr'        => Payment::PingppWxPubQr,
    'redeem'                  => Payment::Redeem,
    'nuandao_b2b'             => Payment::NuandaoB2b
  }

  COUNTRY_PAYMENT_MAPPING = {
    'TW' => %w(paypal neweb/atm neweb/mmk neweb_mpp),
    'CN' => %w(paypal cash_on_delivery neweb/alipay stripe pingpp_alipay pingpp_alipay_wap
               pingpp_wx pingpp_upacp pingpp_bfb pingpp_upacp_wap pingpp_alipay_qr pingpp_alipay_pc_direct
               camera360 pingpp_upacp_pc pingpp_wx_pub_qr nuandao_b2b),
    'default' => %w(paypal stripe)
  }

  def self.for(order)
    clazz = PAYMENT_CLASS_MAPPING[order.payment]
    if clazz
      clazz.new(order)
    else
      fail PaymentMethodNotAllowedError, "The payment method '#{order.payment}' is not supported!"
    end
  end

  def initialize(order)
    @order = order
  end

  # 用於 Orders#pay, 建立/檢查並儲存 payment info
  def pay
    raise 'Not yet implemented!'
  end

  #
  # 檢查金流端是否已收款
  #
  # @return boolean
  def paid?
    raise 'Not yet implemented!'
  end

  def to_hash
    { payment_method: @order.payment }
  end

  def order_number
    fail_count = @order.activities.where(key: 'pay_fail').count
    if fail_count > 0
      "#{@order.order_no}-#{fail_count}"
    else
      @order.order_no
    end
  end

  def free_checking
    free = (@order.price == 0)
    if free
      @order.logcraft_extra_info = to_hash
      @order.pay!
      @order.create_activity(:paid)
    end
    free
  end

  # 僅用於建立refund資訊記錄，而非真的進行退款；會用到進行退款的部份實作在stripe_service, paypal_service裡
  def refund(amount, params = {})
    if @order.can_refund?
      amount = amount.to_f
      note = params[:note]
      if (amount != 0) && (@order.price_after_refund >= amount)
        @order.refunds.create(amount: amount, note: note)
        @order.part_refund! if @order.price_after_refund > 0
        @order.refund! if @order.price_after_refund == 0
        return true
      elsif @order.price_after_refund < amount
        raise NegativeRefundError
      elsif amount == 0
        raise InvalidRefundError
      end
    end
  end

  def name
    I18n.t("activerecord.attributes.order.payment_#{@order.payment}")
  end

  class Error < StandardError
  end

  class NegativeRefundError < ApplicationError
    def message
      I18n.t('orders.show.h3_refund.error_messages.price_after_refund_less_than_zero')
    end
  end

  class InvalidRefundError < ApplicationError
    def message
      I18n.t('orders.show.h3_refund.error_messages.refund_amount_is_zero')
    end
  end
end
