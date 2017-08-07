class StoreOrderPaymentNotificationService
  include Concerns::ActsAsServiceObject
  COMPANY = '噗印商城'.freeze # 要改這字串必須要先去 亿美 送審

  def initialize(order_id)
    @order = Order.find order_id
  end

  protected

  attr_reader :order

  def sms_service
    SmsService.new(provider: :emay_marking)
  end

  def process(_args = {})
    fail NonStoreOrderError unless order.shop?
    if Region.china?
      result = sms_service.execute(phone, notification_message)
      if result[:status] =~ /ok/i
        order.create_activity(:send_store_order_payment_notificiation_sms)
      else
        order.create_activity(:fail_to_send_store_order_payment_notificiation_sms, message: result[:message])
        fail(ServiceObjectError, result[:message])
      end
    else
      order.send_store_receipt
    end
  end

  def notification_message
    "【#{COMPANY}】 谢谢您订购 #{store.name} 的商品，您的订单编号为 #{order.order_no} 。如有问题欢迎致电客服查询"
  end

  def phone
    order.billing_info.phone or fail PhoneNumberMissingError
  end

  def store
    Store.find order.channel
  end
end
