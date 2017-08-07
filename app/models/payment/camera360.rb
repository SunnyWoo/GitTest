require 'httparty'

class Payment::Camera360 < Payment
  def pay
    @order.logcraft_extra_info = to_hash
    if paid?
      @order.pay!
      @order.create_activity(:paid)
    else
      @order.create_activity(:pay_fail)
    end
  end

  def paid?
    Service.paid?(@order.payment_id)
  end

  def to_hash
    super.merge(payment_id: @order.payment_id)
  end

  # # Camera360 的 API
  # endpoint: GET https://mall.camera360.com/v3/order/GetOrderTrue
  # parameter: oid (訂單號)
  # ex: https://mall.camera360.com/v3/order/GetOrderTrue?oid=123456789
  #
  # ## 成功範例
  # GET https://mall.camera360.com/v3/order/GetOrderTrue?oid=215091400000019052
  # data:
  #   oid: 215091400000019052
  # status:  200
  # message: 存在
  #
  # ## 失敗範例
  # GET https://mall.camera360.com/v3/order/GetOrderTrue?oid=123456789
  # data:
  #   oid: 123456789
  # status:  200
  # message: 不存在
  class Service
    include HTTParty

    def self.paid?(order_id)
      get(url_for_order(order_id))['message'] == '存在'
    end

    def self.url_for_order(order_id)
      "https://mall.camera360.com/v3/order/GetOrderTrue?oid=#{order_id}"
    end
  end
end
