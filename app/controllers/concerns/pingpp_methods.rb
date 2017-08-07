module PingppMethods
  # Reference: https://pingxx.com/guidance/config
  # alipay 适用于 App 支付，需要开通支付宝手机支付服务。
  # wx 适用于 App 支付，需要开通微信 App 支付服务。
  # upacp 适用于 App 支付，限 2015 年元旦后的银联新商户使用。需要开通银联全渠道支付服务。
  # bfb 适用于 App 支付，需开通百度钱包移动快捷支付服务。
  # alipay_pc_direct 适用于 PC 支付, 需要开通支付宝即时到帐支付。
  # upacp_pc 适用于 PC 支付, 需要开通银联网关支付。
  # wx_pub_qr 微信公众账号扫码支付，需要开通微信公众账号支付
  CHANNELS = %w(alipay wx upacp bfb alipay_wap upacp_wap alipay_qr
                alipay_pc_direct upacp_pc wx_pub_qr)

  extend ActiveSupport::Concern

  # Actions
  def begin
    if free_order_checking
      render json: { paid: true, message: 'Trigger order#pay!' }
    else
      Timeout.timeout Settings.payment_timeout.to_i do
        @pingpp = Pingpp::Charge.create(pingpp_params(@order, @channel))
        @order.update_attributes(payment_id: @pingpp.id)
        render json: @pingpp
      end
    end
  rescue => e
    handle_pingpp_error(e)
  end

  def verify
    if @order.paid? # if the order is already paid
      render json: { paid: true, message: 'The order is already paid' }
    elsif @charge['paid'] # if the order is not paid yet but Payment::Pingpp is paid
      @order.pay!
      @order.create_activity(:paid)
      render json: { paid: true, message: 'Trigger order#pay!' }
    else
      render json: { paid: false, message: 'Pingpp::Charge is not paid yet' }
    end
  end

  def retrieve
    render json: @charge
  end

  protected

  def handle_pingpp_error(e)
    if e.is_a? Pingpp::PingppError
      fail PingppRailsError, e
    elsif e.is_a? Timeout::Error
      fail ApplicationError, I18n.t('errors.payment_time_out', payment: 'Pingpp')
    else
      fail ApplicationError, e.message
    end
  end

  def pingpp_params(order, channel)
    pingpp_top_level_params(order, channel).merge(charge_extra)
  end

  def pingpp_top_level_params(order, channel)
    {
      order_no: order.order_no,
      app: { id: Settings.pingpp.api_id },
      channel: channel,
      amount: (BigDecimal(order.price.to_s) * 100).to_i,
      client_ip: params[:remote_ip] || request.remote_ip,
      currency: order.currency.downcase,
      subject: 'commandp 噗印商品',
      body: 'commandp 噗印商品'
    }
  end

  def find_order_for_verify
    @order = current_user.orders.find_by!(uuid: params[:uuid])
    fail ApplicationError unless @order.paid? || @order.may_pay?
  end

  def find_pingpp_charge
    begin
      @charge = Pingpp::Charge.retrieve(@order.payment_id)
    rescue => e
      handle_pingpp_error(e)
    end
    fail OrderError, 'no valid Pingpp::Charge object found' unless @charge['order_no'] == @order.order_no
  end

  def find_channel
    @channel ||= @order.payment.split('pingpp_')[1]
    fail OrderPayError, 'payment method is not valid' unless CHANNELS.include?(@channel)
  end

  def alipay_callback_url
    success_url = { success_url: params[:callback_url] }
    return { extra: success_url } unless params[:cancel_url].present?
    { extra: success_url.merge(cancel_url: params[:cancel_url]) }
  end

  def upacp_callback_url
    { extra: { result_url: params[:callback_url] } }
  end

  # product_id String(32) 商户定义的商品id 或者订单号
  def wx_pub_qr_product_id
    { extra: { product_id: @order.order_no } }
  end

  def charge_extra
    case @channel
    when 'alipay_pc_direct', 'alipay_wap'
      alipay_callback_url
    when 'upacp_pc', 'upacp_wap'
      upacp_callback_url
    when 'wx_pub_qr'
      wx_pub_qr_product_id
    else
      {}
    end
  end

  def free_order_checking
    free = (@order.price == 0)
    @order.pay! if free
    free
  end
end
