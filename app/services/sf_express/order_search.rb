class SfExpress::OrderSearch < SfExpressService
  # 订单结果查询接口接口
  # example: SfExpress::OrderSearch.new(Order.last).execute
  # 此处只列取必填参数详细参数见 https://app.asana.com/0/42686877023074/52400225332580  附件
  # http://www.sf-express.com/cn/sc/platform/sd/detail/ordersearch.html
  # _SYSTEM表示如果不提如供，将从系统配置获
  #
  # response
  #   success:
  #       {
  #         "destcode" => "021",
  #         "mailno" => "444436912525",
  #         "origincode" => "021",
  #         "orderid" => "1510231100036CN"
  #       }
  #   error:
  #      {
  #        "error" => "重复下单TW"
  #      }

  mapping :order_search, orderid: nil

  def initialize(order)
    self.order = order
  end

  def generate
    mapping_order_search = mappings[:order_search]
    mapping_order_search[:orderid] = order.order_no
  end

  def request_xml
    generate
    Gyoku.xml(
      'Request' => {
        'Head' => Settings.sf_express.code,
        'Body' => {
          'OrderSearch' => '',
          :attributes! => { 'OrderSearch' => check_params(mappings[:order_search]) }
        }
      },
      :attributes! => { 'Request' => { 'service' => 'OrderSearchService', 'lang' => 'zh-TW' } }
    )
  end

  def result(response_json)
    head = response_json['Response']['Head']
    if head == 'OK'
      response_json['Response']['Body']['OrderResponse']
    elsif head == 'ERR'
      error_result(response_json['Response']['ERROR'])
    else
      fail SfExpressError, response_json
    end
  end
end
