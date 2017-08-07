class SfExpress::Route < SfExpressService
  # 路由查询接口
  # example: SfExpress::Route.new(Order.last).execute
  # 此处只列取必填参数详细参数见 https://app.asana.com/0/42686877023074/52400225332580  附件
  # http://www.sf-express.com/cn/sc/platform/sd/detail/router.html
  # _SYSTEM表示如果不提如供，将从系统配置获取
  # response
  #   success:
  #     {
  #       "RouteResponse" => {
  #         "mailno" => "运单号",
  #         "Route" => [
  #           {
  #             "accept_time" => "路由发生时间",
  #             "accept_address" => "路由发生地点",
  #             "remark" => "详细说明",
  #             "op_code" => "操作码"
  #           },
  #         ]
  #       }
  #     }
  #
  #   error:
  #      {
  #        "error" => "系统发生数据错误或运行时异常"
  #      }

  attr_accessor :mailno
  mapping :route, tracking_type: 2,    # 1：根据顺丰运单号查询;2：根据客户订单号查询
                  tracking_number: '', # 查询号
                  method_type: 1       # 1：标准路由查询;2：定制路由查询

  def initialize(order, mailno = nil)
    self.order = order
    self.mailno = mailno
  end

  def generate
    mapping_order_confirm = mappings[:route]
    if mailno.present?
      mapping_order_confirm[:tracking_type] = 1
      mapping_order_confirm[:tracking_number] = mailno
    else
      mapping_order_confirm[:tracking_type] = 2
      mapping_order_confirm[:tracking_number] = order.order_no
    end
  end

  def request_xml
    generate
    Gyoku.xml(
      'Request' => {
        'Head' => Settings.sf_express.code,
        'Body' => {
          'RouteRequest' => '',
          :attributes! => { 'RouteRequest' => check_params(mappings[:route]) }
        }
      }, :attributes! => { 'Request' => { 'service' => 'RouteService', 'lang' => 'zh-TW' } }
    )
  end

  def result(response_json)
    head = response_json['Response']['Head']
    if head == 'OK'
      response_json['Response']['Body']
    elsif head == 'ERR'
      error_result(response_json['Response']['ERROR'])
    else
      fail SfExpressError, response_json
    end
  end
end
