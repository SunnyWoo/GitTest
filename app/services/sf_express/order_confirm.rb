class SfExpress::OrderConfirm < SfExpressService
  # 订单确认/取消接口
  # example: SfExpress::OrderConfirm.new(Order.last, 1).execute
  # 此处只列取必填参数详细参数见 https://app.asana.com/0/42686877023074/52400225332580  附件
  # http://www.sf-express.com/cn/sc/platform/sd/detail/orderconfirm.html
  # _SYSTEM表示如果不提如供，将从系统配置获
  #
  # response
  #   success:
  #       {
  #         "res_status" => "操作成功",
  #         "orderid" => "159H005677AUqwessdsdadqw"
  #       }
  #   error:
  #      {
  #        "error" => "订单已确认或已取消"
  #      }

  attr_accessor :dealtype

  mapping :order_confirm, orderid: '',          # 客户订单号
                          mailno: '_SYSTEM',    # 顺丰母运单号(如果 dealtype=1，必填)
                          dealtype: '_SYSTEM'   # 客户订单操作标识 1：确认 2：取消

  # dealtype: integer  1-确认; 2-取消
  def initialize(order, dealtype)
    self.order = order
    self.dealtype = dealtype
  end

  def generate
    mapping_order_confirm = mappings[:order_confirm]
    mapping_order_confirm[:orderid] = order.order_no
    mapping_order_confirm[:dealtype] = dealtype
  end

  def request_xml
    generate
    Gyoku.xml(
      'Request' => {
        'Head' => Settings.sf_express.code,
        'Body' => {
          'OrderConfirm' => '',
          :attributes! => { 'OrderConfirm' => check_params(mappings[:order_confirm]) }
        }
      }, :attributes! => { 'Request' => { 'service' => 'OrderConfirmService', 'lang' => 'zh-TW' } }
    )
  end

  def result(response_json)
    head = response_json['Response']['Head']
    if head == 'OK'
      res_status = response_json['Response']['Body']['OrderConfirmResponse']['res_status']
      response_json['Response']['Body']['OrderConfirmResponse']['res_status'] = ok_status(res_status)
      response_json['Response']['Body']['OrderConfirmResponse']
    elsif head == 'ERR'
      error_result(response_json['Response']['ERROR'])
    else
      fail SfExpressError, response_json
    end
  end

  def ok_status(code)
    case code.to_i
    when 1
      '客户订单号与顺丰运单不匹配'
    when 2
      '操作成功'
    else
      ''
    end
  end
end
